include_recipe 'chef-openstack::common'

packages = %w[neutron-l3-agent
              neutron-dhcp-agent
              neutron-metadata-agent]

network_services = %w[neutron-dhcp-agent
                      neutron-l3-agent
                      neutron-metadata-agent]

packages.each do |pkg|
  package pkg do
    action :install
  end
end

include_recipe 'chef-openstack::neutron-common'

bash 'grant privileges' do
  not_if 'grep neutron /etc/sudoers'
  code <<-CODE
  echo 'neutron ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  CODE
end

network_services.each do |srv|
  service srv do
    provider Chef::Provider::Service::Upstart
    action :nothing
  end
end

template '/etc/neutron/dhcp_agent.ini' do
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/dhcp_agent.ini.erb'
  notifies :restart, resources(:service => 'neutron-dhcp-agent')
end

template '/etc/neutron/lbaas_agent.ini' do
  source 'neutron/lbaas_agent.ini.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'neutron-lbaas-agent')
end

template '/etc/neutron/metadata_agent.ini' do
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/metadata_agent.ini.erb'
  notifies :restart, resources(:service => 'neutron-metadata-agent')
end

template '/etc/neutron/l3_agent.ini' do
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/l3_agent.ini.erb'
  notifies :restart, resources(:service => 'neutron-l3-agent')
end

template '/root/.openrc' do
  source 'keystone/openrc.erb'
  owner 'root'
  group 'root'
  mode '0600'
end

template 'neutron network node config' do
  path '/etc/neutron/neutron.conf'
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/neutron.conf.erb'

  notifies :restart, resources(:service => 'neutron-l3-agent'), :immediately
  notifies :restart, resources(:service => 'neutron-plugin-openvswitch-agent'), :immediately
  notifies :restart, resources(:service => 'neutron-metadata-agent'), :immediately
  notifies :restart, resources(:service => 'openvswitch-switch'), :immediately
  notifies :restart, resources(:service => 'neutron-lbaas-agent'), :immediately
end


# If there isn't a public and private portable block defined, we won't create
# the default networks based on them. They can be created manually at any time
# after the installation has taken place.

keystone_auth_url = "http://#{node[:keystone][:private_ip]}:" \
                    "#{node['keystone']['config']['public_port']}/v2.0"

if (node['neutron']['softlayer_private_portable'] \
    && node['neutron']['softlayer_public_portable'])

  # Calculate the SoftLayer local subnet information
  require 'ipaddr'

  sl_private = IPAddr.new(node['neutron']['softlayer_private_portable'])
  range = sl_private.to_range.to_a
  sl_private_router = range[1]  # Gateway for SoftLayer bridged network
  sl_private_host_start = range[2]  # Starting and ending OpenStack allocatable IPs
  sl_private_host_end = range[-2]

  sl_public = IPAddr.new(node['neutron']['softlayer_public_portable'])
  range = sl_public.to_range.to_a
  sl_public_router = range[1]  #Gateway for L3 router.


  # Load SoftLayer configuration and call bash to create the SoftLayer Neutron
  # networks. This creates a Neutron GRE network which is attached to the
  # Neutron L3 router. The router's gateway is the public SoftLayer network.
  # Floating IPs can be assigned across the router. The private network is
  # bridged only; more portable blocks must be ordered to attach additional
  # devices.

  bash "Create SoftLayer Neutron networks for #{node.chef_environment}" do

    node_network = node['neutron']['network']
    environment 'OS_USERNAME' => 'admin',
                'OS_PASSWORD' => node[:admin][:password],
                'OS_TENANT_NAME' => 'admin',
                'OS_AUTH_URL' => keystone_auth_url

    code <<-EOH

      # GRE network for OpenStack
      neutron net-create \
        #{node_network['openstack_network_name']} \
        --provider:network_type=gre \
        --provider:segmentation_id=1 \
        --shared
      neutron subnet-create \
        --name #{node_network['openstack_subnet_name']} \
        --dns-nameserver #{node_network['public_nameserver_1']} \
        --dns-nameserver #{node_network['public_nameserver_2']} \
        #{node_network['openstack_network_name']} \
        #{node_network['openstack_network_cidr']}

      # Public network based on bridge
      neutron net-create \
        #{node_network['public_network_name']} \
        --provider:network_type=flat \
        --provider:physical_network=#{node_network['public_physical_network_name']} \
        --router:external=True \
        --shared
      neutron subnet-create \
        --name #{node_network['public_subnet_name']} \
        --gateway #{sl_public_router.to_s} \
        --dns-nameserver #{node_network['public_nameserver_1']} \
        --dns-nameserver #{node_network['public_nameserver_2']} \
        #{node_network['public_network_name']} \
        #{node['neutron']['softlayer_public_portable']}

      # Private network based on bridge (no router)
      neutron net-create #{node_network['private_network_name']} \
        --provider:network_type=flat \
        --provider:physical_network=#{node_network['private_physical_network_name']} \
        --router:external=False --shared
      neutron subnet-create \
        --name #{node_network['private_subnet_name']} \
        --no-gateway \
        --allocation-pool start=#{sl_private_host_start.to_s},end=#{sl_private_host_end.to_s} \
        --host-route destination=#{node_network['softlayer_private_network_cidr']},nexthop=#{sl_private_router.to_s} \
        --dns-nameserver #{node_network['private_nameserver_1']} \
        --dns-nameserver #{node_network['private_nameserver_2']} \
        #{node_network['private_network_name']} \
        #{node['neutron']['softlayer_private_portable']}

      neutron router-create \
        #{node_network['public_l3_router_name']}
      neutron router-gateway-set \
        #{node_network['public_l3_router_name']} \
        #{node_network['public_network_name']}
      neutron router-interface-add \
        #{node_network['public_l3_router_name']} \
        #{node_network['openstack_subnet_name']}

      neutron security-group-create \
        #{node_network['security_group_name']}
      neutron security-group-rule-create \
        --direction ingress \
        --ethertype IPv4 \
        --protocol tcp \
        --port-range-min 22 \
        --port-range-max 22 \
        #{node_network['security_group_name']}
      neutron security-group-rule-create \
        --direction ingress \
        --ethertype IPv4 \
        --protocol icmp \
        #{node_network['security_group_name']}
    EOH

    not_if "neutron router-list | grep \"#{node_network['public_l3_router_name'].to_s}\""

  end

else

  bash 'Create a default OpenStack GRE Network' do

    node_network = node['neutron']['network']
    environment 'OS_USERNAME' => 'admin',
                'OS_PASSWORD' => node[:admin][:password],
                'OS_TENANT_NAME' => 'admin',
                'OS_AUTH_URL' => keystone_auth_url

    code <<-EOH

      # GRE network for OpenStack
      neutron net-create \
        #{node_network['openstack_network_name']} \
        --provider:network_type=gre \
        --provider:segmentation_id=1 \
        --shared
      neutron subnet-create \
        --name #{node_network['openstack_subnet_name']} \
        --dns-nameserver #{node_network['public_nameserver_1']} \
        --dns-nameserver #{node_network['public_nameserver_2']} \
        #{node_network['openstack_network_name']} \
        #{node_network['openstack_network_cidr']}

      neutron router-create \
        #{node_network['public_l3_router_name']}
      neutron router-interface-add \
        #{node_network['public_l3_router_name']} \
        #{node_network['openstack_subnet_name']}

      neutron security-group-create \
        #{node_network['security_group_name']}
      neutron security-group-rule-create \
        --direction ingress \
        --ethertype IPv4 \
        --protocol tcp \
        --port-range-min 22 \
        --port-range-max 22 \
        #{node_network['security_group_name']}
      neutron security-group-rule-create \
        --direction ingress \
        --ethertype IPv4 \
        --protocol icmp \
        #{node_network['security_group_name']}
    EOH

    not_if "neutron router-list | grep \"#{node_network['public_l3_router_name'].to_s}\""

  end


end
