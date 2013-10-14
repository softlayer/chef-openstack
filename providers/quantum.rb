
#Setup the softlayer quantum network.  Then, define the L3 services based on the quantum object ID's
action :setup_softlayer_networks do 

	bash "Create quantum network for region" do
		environment "OS_USERNAME" => "admin",
					"OS_PASSWORD" => node[:admin][:password],
					"OS_TENANT_NAME" => "admin",
					"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:5000/v2.0",
					
					
					"QUANTUM_STACK_NET_NAME" => "public-NAT",
					"QUANTUM_STACK_SUBNET_NAME"  => "public-nat-subnet",
					
					"QUANTUM_PUB_NET_NAME" => "softlayer-public",
					"QUANTUM_PUB_SUBNET_NAME" => "sl-public-subnet",
					"QUANTUM_PUB_PHYS_NET" => "slpublic1",
					
					"QUANTUM_PRIV_NET_NAME" => "softlayer-private",
					"QUANTUM_PRIV_SUBNET_NAME" => "sl-private-subnet",
					"QUANTUM_PRIV_PHYS_NET" => "slprivate1",

					"QUANTUM_SL_STACK_NET_NAME" => "private-NAT",
					"QUANTUM_SL_STACK_SUBNET_NAME"  => "private-nat-subnet",


					"QUANTUM_PUBLIC_ROUTER_NAME" => "public-router",
					"QUANTUM_PRIVATE_ROUTER_NAME" => "private-router",
					"QUANTUM_SECGROUP_NAME" => "basic-ssh-icmp",

					"STACK_PRIVATE_CIDR" => "172.20.1.0/24",
					"SL_PRIVATE_CIDR" => "172.10.1.0/24",
					"PORTABLE_PRIVATE_CIDR" => new_resource.private_cidr,
					"PORTABLE_PUBLIC_CIDR" => new_resource.public_cidr,
					"NS_PUBLIC_IP_1" => "8.8.8.8",
					"NS_PUBLIC_IP_2" => "8.8.4.4",
					"NS_PRIVATE_IP_1" => "10.0.80.11",
					"NS_PRIVATE_IP_2" => "10.0.80.12"
					
		code <<-EOH

			#Public networking
			quantum net-create ${QUANTUM_STACK_NET_NAME} --provider:network_type=gre --provider:segmentation_id=1 --shared
			quantum subnet-create --name ${QUANTUM_STACK_SUBNET_NAME} --dns-nameserver ${NS_PUBLIC_IP_1} --dns-nameserver ${NS_PUBLIC_IP_2} ${QUANTUM_STACK_NET_NAME} ${STACK_PRIVATE_CIDR}

			quantum net-create ${QUANTUM_PUB_NET_NAME} --provider:network_type=flat --provider:physical_network=${QUANTUM_PUB_PHYS_NET} --router:external=True --shared
			quantum subnet-create --name ${QUANTUM_PUB_SUBNET_NAME} --dns-nameserver ${NS_PUBLIC_IP_1} --dns-nameserver ${NS_PUBLIC_IP_2} ${QUANTUM_PUB_NET_NAME} ${PORTABLE_PUBLIC_CIDR}

			quantum router-create ${QUANTUM_PUBLIC_ROUTER_NAME}
			quantum router-gateway-set ${QUANTUM_PUBLIC_ROUTER_NAME} ${QUANTUM_PUB_NET_NAME}
			quantum router-interface-add ${QUANTUM_PUBLIC_ROUTER_NAME} ${QUANTUM_STACK_SUBNET_NAME}


			#Private networking
			quantum net-create ${QUANTUM_SL_STACK_NET_NAME} --provider:network_type=gre --provider:segmentation_id=2 --shared
			quantum subnet-create --name ${QUANTUM_SL_STACK_SUBNET_NAME} --dns-nameserver ${NS_PRIVATE_IP_1} --dns-nameserver ${NS_PRIVATE_IP_2} ${QUANTUM_SL_STACK_NET_NAME} ${SL_PRIVATE_CIDR}

			quantum net-create ${QUANTUM_PRIV_NET_NAME} --provider:network_type=flat --provider:physical_network=${QUANTUM_PRIV_PHYS_NET} --router:external=True --shared
			quantum subnet-create --name ${QUANTUM_PRIV_SUBNET_NAME} --dns-nameserver ${NS_PRIVATE_IP_1} --dns-nameserver ${NS_PRIVATE_IP_2} ${QUANTUM_PRIV_NET_NAME} ${PORTABLE_PRIVATE_CIDR}

			quantum router-create ${QUANTUM_PRIVATE_ROUTER_NAME}
			quantum router-gateway-set ${QUANTUM_PRIVATE_ROUTER_NAME} ${QUANTUM_PRIV_NET_NAME}
			quantum router-interface-add ${QUANTUM_PRIVATE_ROUTER_NAME} ${QUANTUM_SL_STACK_SUBNET_NAME}


			quantum security-group-create ${QUANTUM_SECGROUP_NAME}
			quantum security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 ${QUANTUM_SECGROUP_NAME}
			quantum security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp ${QUANTUM_SECGROUP_NAME}
		EOH

		not_if "quantum router-show ${QUANTUM_PUBLIC_ROUTER_NAME}"

	end
end


#Action for creating multiple L3 object routers, the config files must be populated with the router configuration ID's and network ID's
action :softlayer_l3_config do

	#Find the public router ID
	command = Mixlib::ShellOut.new("quantum", "router-show", "public-router", "--variable", "id", "-f", "shell",

			:environment => {"OS_USERNAME" => "admin",
							"OS_PASSWORD" => node[:admin][:password],
							"OS_TENANT_NAME" => "admin",
							"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:5000/v2.0"})

	command.run_command

	if command.stderr.index("Unable to find router")
		raise "Unable to find router"
	else
		public_router_id = command.stdout.match /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
		puts "\nFound public router with ID #{public_router_id}\n"
	end


	#Find the private router ID
	command = Mixlib::ShellOut.new("quantum", "router-show", "private-router", "--variable", "id", "-f", "shell",

			:environment => {"OS_USERNAME" => "admin",
							"OS_PASSWORD" => node[:admin][:password],
							"OS_TENANT_NAME" => "admin",
							"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:5000/v2.0"})

	command.run_command

	if command.stderr.index("Unable to find router")
		raise "Unable to find router"
	else
		private_router_id = command.stdout.match /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
		puts "\nFound private router with ID #{private_router_id}\n"
	end

	#Find the public network ID
	command = Mixlib::ShellOut.new("quantum", "net-show", "softlayer-public", "--variable", "id", "-f", "shell",

			:environment => {"OS_USERNAME" => "admin",
							"OS_PASSWORD" => node[:admin][:password],
							"OS_TENANT_NAME" => "admin",
							"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:5000/v2.0"})

	command.run_command

	if command.stderr.index("Unable to find network")
		raise "Unable to find router"
	else
		softlayer_public_network_id = command.stdout.match /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
		puts "\nFound public network with ID #{softlayer_public_network_id}\n"
	end


	#Find the private network ID
	command = Mixlib::ShellOut.new("quantum", "net-show", "softlayer-private", "--variable", "id", "-f", "shell",

			:environment => {"OS_USERNAME" => "admin",
							"OS_PASSWORD" => node[:admin][:password],
							"OS_TENANT_NAME" => "admin",
							"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:5000/v2.0"})

	command.run_command

	if command.stderr.index("Unable to find network")
		raise "Unable to find router"
	else
		softlayer_private_network_id = command.stdout.match /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
		puts "\nFound private network with ID #{softlayer_private_network_id}\n"
	end



	template "/etc/quantum/l3_agent_public.ini" do
		source "quantum/l3_agent.ini.erb"
		owner "root"
		group "quantum"
		mode 00644
		variables({
			:router => public_router_id,
			:network => softlayer_public_network_id,
			:bridge => "br-ex"
			})
	end
	
	template "/etc/quantum/l3_agent_private.ini" do
		source "quantum/l3_agent.ini.erb"
		owner "root"
		group "quantum"
		mode 00644
		variables({
			:router => private_router_id,
			:network => softlayer_private_network_id,
			:bridge => "br-priv"
			})
	end


	template "/etc/init/quantum-l3-agent-private.conf" do
		source "quantum/quantum-l3-agent.conf"
		owner "root"
		group "root"
		mode 00644
		variables({
			:agent => "private"
			})
	end
	
	template "/etc/init/quantum-l3-agent-public.conf" do
		source "quantum/quantum-l3-agent.conf"
		owner "root"
		group "root"
		mode 00644
		variables({
			:agent => "public"
			})
	end
	
	link "/etc/init.d/quantum-l3-agent-public" do
		to "/lib/init/upstart-job"
	end

	link "/etc/init.d/quantum-l3-agent-private" do
		to "/lib/init/upstart-job"
	end


	#Softlayer openstack configuration needs support for multiple allocation pools from externel networks.   Multiple L3 services are required.  
	service "quantum-l3-agent" do
		supports :status => true, :restart => true, :reload => true 
		action [ :disable, :stop ]
	end

	service "quantum-l3-agent-public" do
		supports :status => true, :restart => true, :reload => true
		action [ :enable, :start ]
	end

	service "quantum-l3-agent-private" do
		supports :status => true, :restart => true, :reload => true
		action [ :enable, :start ]
	end

	%w[quantum-dhcp-agent quantum-plugin-openvswitch-agent quantum-metadata-agent quantum-lbaas-agent quantum-l3-agent-public quantum-l3-agent-private].each do |srv|
		service srv do
			action :restart
		end
	end

end