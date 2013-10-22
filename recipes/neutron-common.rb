prereq_packages = %w[openvswitch-datapath-dkms]
common_packages = %w[openvswitch-switch
                     neutron-plugin-openvswitch-agent]


prereq_packages.each do |pkg|
  package prereq_packages.join(' ') do
    action :install
  end
end

common_packages.each do |pkg|
  package pkg do
    action :install
  end
end

service 'openvswitch-switch' do
  supports :status => true, :restart => true, :reload => true
  action :nothing
end

service 'neutron-plugin-openvswitch-agent' do
  provider Chef::Provider::Service::Upstart
  action :nothing
end


template 'neutron network node OVS config' do
  path '/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini'
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/ovs_neutron_plugin.ini.erb'
  notifies :restart,
           resources(:service => 'neutron-plugin-openvswitch-agent'),
           :immediately
  notifies :restart,
           resources(:service => 'openvswitch-switch'),
           :immediately
end

bash 'create external bridge' do
  not_if('ovs-vsctl list-br | grep br-ex')
  code <<-CODE
  ovs-vsctl add-br br-ex
  CODE
end

bash 'create SoftLayer private bridge' do
  not_if('ovs-vsctl list-br | grep br-priv')
  code <<-CODE
  ovs-vsctl add-br br-priv
  CODE
end

bash 'create integration bridge' do
  not_if('ovs-vsctl list-br | grep br-int')
  code <<-CODE
  ovs-vsctl add-br br-int
  CODE
end

if node[:node_info][:is_bonded] == 'True'
  template '/etc/network/interfaces' do
    owner 'root'
    group 'neutron'
    mode '0644'
    source 'neutron/interfaces-bonded.erb'
  end
else
  template '/etc/network/interfaces' do
    owner 'root'
    group 'neutron'
    mode '0644'
    source 'neutron/interfaces-nonbonded.erb'
  end
end

private_iface = node[:node_info][:private_iface]
private_cidr = node[:node_info][:private_ip] + '/' + \
               node[:node_info][:private_cidr]

public_iface = node[:node_info][:public_iface]
public_cidr = node[:node_info][:public_ip] + '/' + \
              node[:node_info][:public_cidr]

# Private bridge configuration
if node[:node_info][:private_dest] && node[:node_info][:private_via]
  # SoftLayer hardware
  execute 'Configure SoftLayer internal network bridge' do
    not_if("ip addr show dev br-priv | grep #{node[:node_info][:private_ip]}")

    command "ip addr del #{private_cidr} dev #{private_iface};
             ip addr add #{private_cidr} dev br-priv;
             ovs-vsctl add-port br-priv #{private_iface};
             ip link set dev br-priv up;
             route add -net #{node[:node_info][:private_dest]} \
                        gw #{node[:node_info][:private_via]} \
                        dev br-priv"
    action :run
  end
else
  # Commodity hardware and virtual machines
  execute 'Configure other internal network bridge' do
    not_if("ip addr show dev br-priv | grep #{node[:node_info][:private_ip]}")

    command "ip addr del #{private_cidr} dev #{private_iface};
             ip addr add #{private_cidr} dev br-priv;
             ovs-vsctl add-port br-priv #{private_iface};
             ip link set dev br-priv up"
    action :run
  end
end

# Public bridge configuration
execute 'Configure external network bridge' do
  not_if("ip addr show dev br-ex | grep #{node[:node_info][:public_ip]}")

  command "ip addr del #{public_cidr} dev #{public_iface};
           ip addr add #{public_cidr} dev br-ex;
           ovs-vsctl add-port br-ex #{public_iface};
           ip link set dev br-ex up;
           route add default gw #{node[:node_info][:default_gateway]} br-ex"
  action :run
end
