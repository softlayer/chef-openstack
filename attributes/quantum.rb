default["quantum"]["db"]["name"] = "quantum"
default["quantum"]["db"]["username"] = "quantum"
default["quantum"]["db"]["password"] = "qu4ntum"

default["quantum"]["service_tenant_name"] = "service"
default["quantum"]["service_user"] = "quantum"

default["quantum"]["config"]["debug"] = "False"
default["quantum"]["config"]["verbose"] = "False"
default["quantum"]["config"]["rabbit_password"] = "guest"
default["quantum"]["config"]["notification_level"] = "INFO"
default["quantum"]["config"]["root_helper"] = "sudo"
default["quantum"]["config"]["allow_overlapping_ips"] = "True"
default["quantum"]["config"]["control_exchange"] = "quantum"
default["quantum"]["config"]["bind_host"] = "0.0.0.0"
default["quantum"]["config"]["bind_port"] = "9696"
default["quantum"]["config"]["auth_strategy"] = "keystone"
default["quantum"]["config"]["agent_down_time"] = "15"

#Quantum Quota's
default["quantum"]["config"]["default_quota"] = "-1"
default["quantum"]["config"]["quota_network"] = "10"
default["quantum"]["config"]["quota_subnet"] = "10"
default["quantum"]["config"]["quota_port"] = "100"
default["quantum"]["config"]["quota_security_group"] = "10"
default["quantum"]["config"]["quota_security_group_rule"] = "100"

#dhcp agent
default["quantum"]["dhcp_agent"]["ovs_use_veth"] = "True"
default["quantum"]["dhcp_agent"]["enable_isolated_metadata"] = "True"
default["quantum"]["dhcp_agent"]["use_namespaces"] = "True"
default["quantum"]["dhcp_agent"]["enable_metadata_network"] = "True"

#Metadata agent
default["quantum"]["metadata_agent"]["metadata_proxy_shared_secret"] = "mySuperSekre1"

#OVS config
default["quantum"]["ovs_plugin"]["enable_tunneling"] = "True"
default["quantum"]["ovs_plugin"]["tenant_network_type"] = "gre"
default["quantum"]["ovs_plugin"]["tunnel_id_ranges"] = "1:1000"

#Quantum and Softlayer Network Settings
default["quantum"]["network"]["openstack_network_name"] = "stack-network"
default["quantum"]["network"]["openstack_subnet_name"] = "stack-subnet"
default["quantum"]["network"]["openstack_network_cidr"] = "172.20.1.0/24"

default["quantum"]["network"]["public_l3_router_name"] = "public-router"
default["quantum"]["network"]["public_network_name"] = "softlayer-public"
default["quantum"]["network"]["public_subnet_name"] = "sl-public-subnet"
default["quantum"]["network"]["public_physical_network_name"] = "slpublic1"

default["quantum"]["network"]["private_network_name"] = "softlayer-private"
default["quantum"]["network"]["private_subnet_name"] = "sl-private-subnet"
default["quantum"]["network"]["private_physical_network_name"] = "slprivate1"

default["quantum"]["network"]["softlayer_private_network_cidr"] = "10.0.0.0/8"
default["quantum"]["network"]["public_nameserver_1"] = "8.8.8.8"
default["quantum"]["network"]["public_nameserver_2"] = "8.8.4.4"
default["quantum"]["network"]["private_nameserver_1"] = "10.0.80.11"
default["quantum"]["network"]["private_nameserver_2"] = "10.0.80.12"
default["quantum"]["network"]["softlayer_private_portable"] = nil
default["quantum"]["network"]["softlayer_public_portable"] = nil
# if node.chef_environment == "SanJose2"
# default["quantum"]["network"]["softlayer_private_portable"] = "10.88.28.240/29"
# default["quantum"]["network"]["softlayer_public_portable"] = "198.23.73.148/30"
# end
# if node.chef_environment == "SanJose"
# default["quantum"]["network"]["softlayer_private_portable"] = "10.54.67.64/28"
# default["quantum"]["network"]["softlayer_public_portable"] = "50.97.218.16/29"
# end
# if node.chef_environment == "SanJose3"
# default["quantum"]["network"]["softlayer_private_portable"] = "10.54.17.208/29"
# default["quantum"]["network"]["softlayer_public_portable"] = "50.97.197.224/29"
# end
# if node.chef_environment == "DAL-A"
# default["quantum"]["network"]["softlayer_private_portable"] = "10.96.5.192/27"
# default["quantum"]["network"]["softlayer_public_portable"] = "174.122.15.128/28"
# end
# if node.chef_environment == "DAL-B"
# default["quantum"]["network"]["softlayer_private_portable"] = "10.96.5.224/27"
# default["quantum"]["network"]["softlayer_public_portable"] = "174.122.12.224/28"
# end

default["quantum"]["network"]["security_group_name"] = "basic-ssh-icmp"