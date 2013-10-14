%w[neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent neutron-lbaas-agent].each do |pkg|
	package pkg do 
		action :install
	end
end

include_recipe "chef-openstack::neutron-common"

bash "grant privilegies" do
	not_if "grep neutron /etc/sudoers"
	code <<-CODE
	echo "neutron ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	CODE
end

%w[neutron-dhcp-agent neutron-metadata-agent neutron-lbaas-agent neutron-l3-agent].each do |srv|
	service srv do
		provider Chef::Provider::Service::Upstart
		action :nothing
	end
end

template "/etc/neutron/dhcp_agent.ini" do
	owner "root"
	group "neutron"
	mode "0644"
	source "neutron/dhcp_agent.ini.erb"
	notifies :restart, resources(:service => "neutron-dhcp-agent")
end

template "/etc/neutron/metadata_agent.ini" do
	owner "root"
	group "neutron"
	mode "0644"
	source "neutron/metadata_agent.ini.erb"
	notifies :restart, resources(:service => "neutron-metadata-agent")
end

template "/etc/neutron/l3_agent.ini" do
	owner "root"
	group "neutron"
	mode "0644"
	source "neutron/l3_agent.ini.erb"
	notifies :restart, resources(:service => "neutron-l3-agent")
end

template "/root/.openrc" do
	source "keystone/openrc.erb"
	owner "root"
	group "root"
	mode "0600"
end

template "neutron network node config" do
	path "/etc/neutron/neutron.conf"
	owner "root"
	group "neutron"
	mode "0644"
	source "neutron/neutron.conf.erb"
	notifies :restart, resources(:service => "neutron-l3-agent"), :immediately
	notifies :restart, resources(:service => "neutron-plugin-openvswitch-agent"), :immediately
	notifies :restart, resources(:service => "neutron-metadata-agent"), :immediately
	notifies :restart, resources(:service => "openvswitch-switch"), :immediately
	notifies :restart, resources(:service => "neutron-lbaas-agent"), :immediately
end



#If there isn't a public and private portable block defined, we won't create the default networks based on them.  
#They can be created manually at any time after the installation has taken place.
if ( node["neutron"]["network"]["softlayer_private_portable"] && node["neutron"]["network"]["softlayer_public_portable"] )

	
	#Calculate the softlayer local subnet information
	require 'ipaddr'
	sl_private = IPAddr.new( node["neutron"]["network"]["softlayer_private_portable"] )
	range = sl_private.to_range.to_a
	sl_private_router = range[1]  #Gateway for softlayer bridged network
	sl_private_host_start = range[2]  #starting and ending openstack allocatable IPs
	sl_private_host_end = range[-2]

	sl_public = IPAddr.new( node["neutron"]["network"]["softlayer_public_portable"] )
	range = sl_public.to_range.to_a
	sl_public_router = range[1]  #Gateway for L3 router.
	  

	#Load Softlayer configuration and call bash to create the softlayer neutron(neutron) networks
	#This creates a gre openstack network which is attached to the L3 neutron router.  The router's gateway is the public softlayer network.  Floating IP's
	# can be assigned across the router.   The private network is bridged only, more portable blocks must be ordered to attach additional devices.
	bash "Create Softlayer neutron Networks for #{node.chef_environment}" do

		environment "OS_USERNAME" => "admin",
					"OS_PASSWORD" => node[:admin][:password],
					"OS_TENANT_NAME" => "admin",
					"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:#{node["keystone"]["config"]["public_port"]}/v2.0"
					
		code <<-EOH

			#GRE network for openstack 
			neutron net-create #{node["neutron"]["network"]["openstack_network_name"]} --provider:network_type=gre --provider:segmentation_id=1 --shared
			neutron subnet-create --name #{node["neutron"]["network"]["openstack_subnet_name"]} --dns-nameserver #{node["neutron"]["network"]["public_nameserver_1"]} --dns-nameserver #{node["neutron"]["network"]["public_nameserver_2"]} #{node["neutron"]["network"]["openstack_network_name"]} #{node["neutron"]["network"]["openstack_network_cidr"]}

			#public network based on bridge
			neutron net-create #{node["neutron"]["network"]["public_network_name"]} --provider:network_type=flat --provider:physical_network=#{node["neutron"]["network"]["public_physical_network_name"]} --router:external=True --shared
			neutron subnet-create --name #{node["neutron"]["network"]["public_subnet_name"]} --gateway #{sl_public_router.to_s} --dns-nameserver #{node["neutron"]["network"]["public_nameserver_1"]} --dns-nameserver #{node["neutron"]["network"]["public_nameserver_2"]} #{node["neutron"]["network"]["public_network_name"]} #{node["neutron"]["network"]["softlayer_public_portable"]}

			#private network based on bridge (no router)
			neutron net-create #{node["neutron"]["network"]["private_network_name"]} --provider:network_type=flat --provider:physical_network=#{node["neutron"]["network"]["private_physical_network_name"]} --router:external=False --shared
			neutron subnet-create --name #{node["neutron"]["network"]["private_subnet_name"]} --no-gateway --allocation-pool start=#{sl_private_host_start.to_s},end=#{sl_private_host_end.to_s} --host-route destination=#{node["neutron"]["network"]["softlayer_private_network_cidr"]},nexthop=#{sl_private_router.to_s} --dns-nameserver #{node["neutron"]["network"]["private_nameserver_1"]} --dns-nameserver #{node["neutron"]["network"]["private_nameserver_2"]} #{node["neutron"]["network"]["private_network_name"]} #{node["neutron"]["network"]["softlayer_private_portable"]}

			neutron router-create #{node["neutron"]["network"]["public_l3_router_name"]}
			neutron router-gateway-set #{node["neutron"]["network"]["public_l3_router_name"]} #{node["neutron"]["network"]["public_network_name"]}
			neutron router-interface-add #{node["neutron"]["network"]["public_l3_router_name"]} #{node["neutron"]["network"]["openstack_subnet_name"]}

			neutron security-group-create #{node["neutron"]["network"]["security_group_name"]}
			neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 #{node["neutron"]["network"]["security_group_name"]}
			neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp #{node["neutron"]["network"]["security_group_name"]}
		EOH

		not_if "neutron router-list | grep \"#{node["neutron"]["network"]["public_l3_router_name"].to_s}\""

	end

else

	bash "Create a default Openstack GRE Network" do

		environment "OS_USERNAME" => "admin",
					"OS_PASSWORD" => node[:admin][:password],
					"OS_TENANT_NAME" => "admin",
					"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:#{node["keystone"]["config"]["public_port"]}/v2.0"
					
		code <<-EOH

			#GRE network for openstack 
			neutron net-create #{node["neutron"]["network"]["openstack_network_name"]} --provider:network_type=gre --provider:segmentation_id=1 --shared
			neutron subnet-create --name #{node["neutron"]["network"]["openstack_subnet_name"]} --dns-nameserver #{node["neutron"]["network"]["public_nameserver_1"]} --dns-nameserver #{node["neutron"]["network"]["public_nameserver_2"]} #{node["neutron"]["network"]["openstack_network_name"]} #{node["neutron"]["network"]["openstack_network_cidr"]}

			neutron router-create #{node["neutron"]["network"]["public_l3_router_name"]}
			neutron router-interface-add #{node["neutron"]["network"]["public_l3_router_name"]} #{node["neutron"]["network"]["openstack_subnet_name"]}

			neutron security-group-create #{node["neutron"]["network"]["security_group_name"]}
			neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 #{node["neutron"]["network"]["security_group_name"]}
			neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp #{node["neutron"]["network"]["security_group_name"]}
		EOH

		not_if "neutron router-list | grep \"#{node["neutron"]["network"]["public_l3_router_name"].to_s}\""

	end


end


#Use the neutron LWRP when you need multiple L3 routers configured.  A router for each softlayer public and private networks
# grizzly_neutron "Setup softlayer L3 router config for openstack" do
# 	action :softlayer_l3_config
# end
