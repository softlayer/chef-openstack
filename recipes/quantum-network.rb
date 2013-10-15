%w[quantum-dhcp-agent quantum-l3-agent quantum-metadata-agent quantum-lbaas-agent].each do |pkg|
	package pkg do 
		action :install
	end
end

include_recipe "chef-openstack::quantum-common"

bash "grant privilegies" do
	not_if "grep quantum /etc/sudoers"
	code <<-CODE
	echo "quantum ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	CODE
end

%w[quantum-dhcp-agent quantum-metadata-agent quantum-lbaas-agent quantum-l3-agent].each do |srv|
	service srv do
		provider Chef::Provider::Service::Upstart
		action :nothing
	end
end

template "/etc/quantum/dhcp_agent.ini" do
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/dhcp_agent.ini.erb"
	notifies :restart, resources(:service => "quantum-dhcp-agent")
end

template "/etc/quantum/metadata_agent.ini" do
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/metadata_agent.ini.erb"
	notifies :restart, resources(:service => "quantum-metadata-agent")
end

template "/root/.openrc" do
	source "keystone/openrc.erb"
	owner "root"
	group "root"
	mode "0600"
end

template "Quantum network node config" do
	path "/etc/quantum/quantum.conf"
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/quantum.conf.erb"
	notifies :restart, resources(:service => "quantum-l3-agent"), :immediately
	notifies :restart, resources(:service => "quantum-plugin-openvswitch-agent"), :immediately
	notifies :restart, resources(:service => "quantum-metadata-agent"), :immediately
	notifies :restart, resources(:service => "openvswitch-switch"), :immediately
	notifies :restart, resources(:service => "quantum-lbaas-agent"), :immediately
end



#If there isn't a public and private portable block defined, we won't create the default networks based on them.  
#They can be created manually at any time after the installation has taken place.
if ( node["quantum"]["network"]["softlayer_private_portable"] && node["quantum"]["network"]["softlayer_public_portable"] )

	
	#Calculate the softlayer local subnet information
	require 'ipaddr'
	sl_private = IPAddr.new( node["quantum"]["network"]["softlayer_private_portable"] )
	range = sl_private.to_range.to_a
	sl_private_router = range[1]  #Gateway for softlayer bridged network
	sl_private_host_start = range[2]  #starting and ending openstack allocatable IPs
	sl_private_host_end = range[-2]

	sl_public = IPAddr.new( node["quantum"]["network"]["softlayer_public_portable"] )
	range = sl_public.to_range.to_a
	sl_public_router = range[1]  #Gateway for L3 router.
	  

	#Load Softlayer configuration and call bash to create the softlayer quantum(neutron) networks
	#This creates a gre openstack network which is attached to the L3 quantum router.  The router's gateway is the public softlayer network.  Floating IP's
	# can be assigned across the router.   The private network is bridged only, more portable blocks must be ordered to attach additional devices.
	bash "Create Softlayer Quantum Networks for #{node.chef_environment}" do

		environment "OS_USERNAME" => "admin",
					"OS_PASSWORD" => node[:admin][:password],
					"OS_TENANT_NAME" => "admin",
					"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:#{node["keystone"]["config"]["public_port"]}/v2.0"
					
		code <<-EOH

			#GRE network for openstack 
			quantum net-create #{node["quantum"]["network"]["openstack_network_name"]} --provider:network_type=gre --provider:segmentation_id=1 --shared
			quantum subnet-create --name #{node["quantum"]["network"]["openstack_subnet_name"]} --dns-nameserver #{node["quantum"]["network"]["public_nameserver_1"]} --dns-nameserver #{node["quantum"]["network"]["public_nameserver_2"]} #{node["quantum"]["network"]["openstack_network_name"]} #{node["quantum"]["network"]["openstack_network_cidr"]}

			#public network based on bridge
			quantum net-create #{node["quantum"]["network"]["public_network_name"]} --provider:network_type=flat --provider:physical_network=#{node["quantum"]["network"]["public_physical_network_name"]} --router:external=True --shared
			quantum subnet-create --name #{node["quantum"]["network"]["public_subnet_name"]} --gateway #{sl_public_router.to_s} --dns-nameserver #{node["quantum"]["network"]["public_nameserver_1"]} --dns-nameserver #{node["quantum"]["network"]["public_nameserver_2"]} #{node["quantum"]["network"]["public_network_name"]} #{node["quantum"]["network"]["softlayer_public_portable"]}

			#private network based on bridge (no router)
			quantum net-create #{node["quantum"]["network"]["private_network_name"]} --provider:network_type=flat --provider:physical_network=#{node["quantum"]["network"]["private_physical_network_name"]} --router:external=False --shared
			quantum subnet-create --name #{node["quantum"]["network"]["private_subnet_name"]} --no-gateway --allocation-pool start=#{sl_private_host_start.to_s},end=#{sl_private_host_end.to_s} --host-route destination=#{node["quantum"]["network"]["softlayer_private_network_cidr"]},nexthop=#{sl_private_router.to_s} --dns-nameserver #{node["quantum"]["network"]["private_nameserver_1"]} --dns-nameserver #{node["quantum"]["network"]["private_nameserver_2"]} #{node["quantum"]["network"]["private_network_name"]} #{node["quantum"]["network"]["softlayer_private_portable"]}

			quantum router-create #{node["quantum"]["network"]["public_l3_router_name"]}
			quantum router-gateway-set #{node["quantum"]["network"]["public_l3_router_name"]} #{node["quantum"]["network"]["public_network_name"]}
			quantum router-interface-add #{node["quantum"]["network"]["public_l3_router_name"]} #{node["quantum"]["network"]["openstack_subnet_name"]}

			quantum security-group-create #{node["quantum"]["network"]["security_group_name"]}
			quantum security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 #{node["quantum"]["network"]["security_group_name"]}
			quantum security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp #{node["quantum"]["network"]["security_group_name"]}
		EOH

		not_if "quantum router-list | grep \"#{node["quantum"]["network"]["public_l3_router_name"].to_s}\""

	end

else

	bash "Create a default Openstack GRE Network" do

		environment "OS_USERNAME" => "admin",
					"OS_PASSWORD" => node[:admin][:password],
					"OS_TENANT_NAME" => "admin",
					"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:#{node["keystone"]["config"]["public_port"]}/v2.0"
					
		code <<-EOH

			#GRE network for openstack 
			quantum net-create #{node["quantum"]["network"]["openstack_network_name"]} --provider:network_type=gre --provider:segmentation_id=1 --shared
			quantum subnet-create --name #{node["quantum"]["network"]["openstack_subnet_name"]} --dns-nameserver #{node["quantum"]["network"]["public_nameserver_1"]} --dns-nameserver #{node["quantum"]["network"]["public_nameserver_2"]} #{node["quantum"]["network"]["openstack_network_name"]} #{node["quantum"]["network"]["openstack_network_cidr"]}

			quantum router-create #{node["quantum"]["network"]["public_l3_router_name"]}
			quantum router-interface-add #{node["quantum"]["network"]["public_l3_router_name"]} #{node["quantum"]["network"]["openstack_subnet_name"]}

			quantum security-group-create #{node["quantum"]["network"]["security_group_name"]}
			quantum security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 #{node["quantum"]["network"]["security_group_name"]}
			quantum security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp #{node["quantum"]["network"]["security_group_name"]}
		EOH

		not_if "quantum router-list | grep \"#{node["quantum"]["network"]["public_l3_router_name"].to_s}\""

	end


end


#Use the quantum LWRP when you need multiple L3 routers configured.  A router for each softlayer public and private networks
# chef-openstack_quantum "Setup softlayer L3 router config for openstack" do
# 	action :softlayer_l3_config
# end
