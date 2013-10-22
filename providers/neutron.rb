# Set up the SoftLayer Neutron network. Then, define the L3 services based on
# the Neutron object IDs

services = %w[neutron-dhcp-agent
              neutron-plugin-openvswitch-agent
              neutron-metadata-agent
              neutron-lbaas-agent
              neutron-l3-agent-public
              neutron-l3-agent-private]

uuid_regex = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/


action :setup_softlayer_networks do

  bash "Create Neutron network for region" do
    environment "OS_USERNAME" => "admin",
                "OS_PASSWORD" => node[:admin][:password],
                "OS_TENANT_NAME" => "admin",
                "OS_AUTH_URL" => keystone_auth_url,

                "NEUTRON_STACK_NET_NAME" => "public-nat",
                "NEUTRON_STACK_SUBNET_NAME"  => "public-nat-subnet",

                "NEUTRON_PUB_NET_NAME" => "softlayer-public",
                "NEUTRON_PUB_SUBNET_NAME" => "softlayer-public-subnet",
                "NEUTRON_PUB_PHYS_NET" => "slpublic1",

                "NEUTRON_PRIV_NET_NAME" => "softlayer-private",
                "NEUTRON_PRIV_SUBNET_NAME" => "softlayer-private-subnet",
                "NEUTRON_PRIV_PHYS_NET" => "slprivate1",

                "NEUTRON_SL_STACK_NET_NAME" => "private-nat",
                "NEUTRON_SL_STACK_SUBNET_NAME"  => "private-nat-subnet",


                "NEUTRON_PUBLIC_ROUTER_NAME" => "public-router",
                "NEUTRON_PRIVATE_ROUTER_NAME" => "private-router",
                "NEUTRON_SECGROUP_NAME" => "basic-ssh-icmp",

                "STACK_PRIVATE_CIDR" => "172.20.1.0/24",
                "SL_PRIVATE_CIDR" => "172.10.1.0/24",
                "PORTABLE_PRIVATE_CIDR" => new_resource.private_cidr,
                "PORTABLE_PUBLIC_CIDR" => new_resource.public_cidr,
                "NS_PUBLIC_IP_1" => "8.8.8.8",
                "NS_PUBLIC_IP_2" => "8.8.4.4",
                "NS_PRIVATE_IP_1" => "10.0.80.11",
                "NS_PRIVATE_IP_2" => "10.0.80.12"

    code <<-EOH

      # Public networking
      neutron net-create ${NEUTRON_STACK_NET_NAME} --provider:network_type=gre --provider:segmentation_id=1 --shared
      neutron subnet-create --name ${NEUTRON_STACK_SUBNET_NAME} --dns-nameserver ${NS_PUBLIC_IP_1} --dns-nameserver ${NS_PUBLIC_IP_2} ${NEUTRON_STACK_NET_NAME} ${STACK_PRIVATE_CIDR}

      neutron net-create ${NEUTRON_PUB_NET_NAME} --provider:network_type=flat --provider:physical_network=${NEUTRON_PUB_PHYS_NET} --router:external=True --shared
      neutron subnet-create --name ${NEUTRON_PUB_SUBNET_NAME} --dns-nameserver ${NS_PUBLIC_IP_1} --dns-nameserver ${NS_PUBLIC_IP_2} ${NEUTRON_PUB_NET_NAME} ${PORTABLE_PUBLIC_CIDR}

      neutron router-create ${NEUTRON_PUBLIC_ROUTER_NAME}
      neutron router-gateway-set ${NEUTRON_PUBLIC_ROUTER_NAME} ${NEUTRON_PUB_NET_NAME}
      neutron router-interface-add ${NEUTRON_PUBLIC_ROUTER_NAME} ${NEUTRON_STACK_SUBNET_NAME}


      # Private networking
      neutron net-create ${NEUTRON_SL_STACK_NET_NAME} --provider:network_type=gre --provider:segmentation_id=2 --shared
      neutron subnet-create --name ${NEUTRON_SL_STACK_SUBNET_NAME} --dns-nameserver ${NS_PRIVATE_IP_1} --dns-nameserver ${NS_PRIVATE_IP_2} ${NEUTRON_SL_STACK_NET_NAME} ${SL_PRIVATE_CIDR}

      neutron net-create ${NEUTRON_PRIV_NET_NAME} --provider:network_type=flat --provider:physical_network=${NEUTRON_PRIV_PHYS_NET} --router:external=True --shared
      neutron subnet-create --name ${NEUTRON_PRIV_SUBNET_NAME} --dns-nameserver ${NS_PRIVATE_IP_1} --dns-nameserver ${NS_PRIVATE_IP_2} ${NEUTRON_PRIV_NET_NAME} ${PORTABLE_PRIVATE_CIDR}

      neutron router-create ${NEUTRON_PRIVATE_ROUTER_NAME}
      neutron router-gateway-set ${NEUTRON_PRIVATE_ROUTER_NAME} ${NEUTRON_PRIV_NET_NAME}
      neutron router-interface-add ${NEUTRON_PRIVATE_ROUTER_NAME} ${NEUTRON_SL_STACK_SUBNET_NAME}


      neutron security-group-create ${NEUTRON_SECGROUP_NAME}
      neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 ${NEUTRON_SECGROUP_NAME}
      neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp ${NEUTRON_SECGROUP_NAME}
    EOH

    not_if "neutron router-show ${NEUTRON_PUBLIC_ROUTER_NAME}"

  end
end


# An action to create multiple L3 object routers. The config files must be
# populated with the router configuration IDs and network IDs.

action :softlayer_l3_config do

  # Find the public router ID
  command = Mixlib::ShellOut.new("neutron", "router-show",
                                 "public-router",
                                 "--variable", "id",
                                 "-f", "shell",
                                 :environment => env)
  command.run_command

  if command.stderr.index("Unable to find router")
    raise "Unable to find router"
  else
    public_router_id = command.stdout.match uuid_regex
    puts "\nFound public router with ID #{public_router_id}"
  end

  # Find the private router ID
  command = Mixlib::ShellOut.new("neutron", "router-show",
                                 "private-router",
                                 "--variable", "id",
                                 "-f", "shell",
                                 :environment => env)
  command.run_command

  if command.stderr.index("Unable to find router")
    raise "Unable to find router"
  else
    private_router_id = command.stdout.match uuid_regex
    puts "\nFound private router with ID #{private_router_id}"
  end

  # Find the public network ID
  command = Mixlib::ShellOut.new("neutron", "net-show",
                                 "softlayer-public",
                                 "--variable", "id",
                                 "-f", "shell",
                                 :environment => env)
  command.run_command

  if command.stderr.index("Unable to find network")
    raise "Unable to find router"
  else
    softlayer_public_network_id = command.stdout.match uuid_regex
    puts "\nFound public network with ID #{softlayer_public_network_id}"
  end


  #Find the private network ID
  command = Mixlib::ShellOut.new("neutron", "net-show",
                                 "softlayer-private",
                                 "--variable", "id",
                                 "-f", "shell",
                                 :environment => env)
  command.run_command

  if command.stderr.index("Unable to find network")
    raise "Unable to find router"
  else
    softlayer_private_network_id = command.stdout.match uuid_regex
    puts "\nFound private network with ID #{softlayer_private_network_id}"
  end



  template "/etc/neutron/l3_agent_public.ini" do
    source "neutron/l3_agent.ini.erb"
    owner "root"
    group "neutron"
    mode 00644
    variables({ :router => public_router_id,
                :network => softlayer_public_network_id,
                :bridge => "br-ex"
                })
  end

  template "/etc/neutron/l3_agent_private.ini" do
    source "neutron/l3_agent.ini.erb"
    owner "root"
    group "neutron"
    mode 00644
    variables({ :router => private_router_id,
                :network => softlayer_private_network_id,
                :bridge => "br-priv"
                })
  end


  template "/etc/init/neutron-l3-agent-private.conf" do
    source "neutron/neutron-l3-agent.conf"
    owner "root"
    group "root"
    mode 00644
    variables({ :agent => "private" })
  end

  template "/etc/init/neutron-l3-agent-public.conf" do
    source "neutron/neutron-l3-agent.conf"
    owner "root"
    group "root"
    mode 00644
    variables({ :agent => "public" })
  end

  link "/etc/init.d/neutron-l3-agent-public" do
    to "/lib/init/upstart-job"
  end

  link "/etc/init.d/neutron-l3-agent-private" do
    to "/lib/init/upstart-job"
  end


  # SoftLayer OpenStack configuration needs support for multiple allocation
  # pools from external networks. Multiple L3 services are required.
  service "neutron-l3-agent" do
    supports :status => true, :restart => true, :reload => true
    action [ :disable, :stop ]
  end

  %w[neutron-l3-agent-public neutron-l3-agent-private].each do |srv|
    service srv do
      supports :status => true, :restart => true, :reload => true
      action [ :enable, :start ]
    end
  end

  services.each do |srv|
    service srv do
      action :restart
    end
  end

end
