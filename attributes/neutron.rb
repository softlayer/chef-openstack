default["neutron"]["db"]["name"] = "neutron"
default["neutron"]["db"]["username"] = "neutron"
default["neutron"]["db"]["password"] = "qu4ntum"

default["neutron"]["service_tenant_name"] = "service"
default["neutron"]["service_user"] = "neutron"

default["neutron"]["config"]["debug"] = "False"
default["neutron"]["config"]["verbose"] = "False"
default["neutron"]["config"]["rabbit_password"] = "guest"
default["neutron"]["config"]["notification_level"] = "INFO"
default["neutron"]["config"]["root_helper"] = "sudo"
default["neutron"]["config"]["allow_overlapping_ips"] = "True"
default["neutron"]["config"]["control_exchange"] = "neutron"
default["neutron"]["config"]["bind_host"] = "0.0.0.0"
default["neutron"]["config"]["bind_port"] = "9696"
default["neutron"]["config"]["auth_strategy"] = "keystone"
default["neutron"]["config"]["agent_down_time"] = "15"

#neutron Quota's
default["neutron"]["config"]["default_quota"] = "-1"
default["neutron"]["config"]["quota_network"] = "10"
default["neutron"]["config"]["quota_subnet"] = "10"
default["neutron"]["config"]["quota_port"] = "100"
default["neutron"]["config"]["quota_security_group"] = "10"
default["neutron"]["config"]["quota_security_group_rule"] = "100"

#dhcp agent
default["neutron"]["dhcp_agent"]["ovs_use_veth"] = "True"
default["neutron"]["dhcp_agent"]["enable_isolated_metadata"] = "True"
default["neutron"]["dhcp_agent"]["use_namespaces"] = "True"
default["neutron"]["dhcp_agent"]["enable_metadata_network"] = "True"

#Metadata agent
default["neutron"]["metadata_agent"]["metadata_proxy_shared_secret"] = "mySuperSekre1"

#OVS config
default["neutron"]["ovs_plugin"]["enable_tunneling"] = "True"
default["neutron"]["ovs_plugin"]["tenant_network_type"] = "gre"
default["neutron"]["ovs_plugin"]["tunnel_id_ranges"] = "1:1000"

#neutron and Softlayer Network Settings
default["neutron"]["network"]["openstack_network_name"] = "stack-network"
default["neutron"]["network"]["openstack_subnet_name"] = "stack-subnet"
default["neutron"]["network"]["openstack_network_cidr"] = "172.20.1.0/24"

default["neutron"]["network"]["public_l3_router_name"] = "public-router"
default["neutron"]["network"]["public_network_name"] = "softlayer-public"
default["neutron"]["network"]["public_subnet_name"] = "sl-public-subnet"
default["neutron"]["network"]["public_physical_network_name"] = "slpublic1"

default["neutron"]["network"]["private_network_name"] = "softlayer-private"
default["neutron"]["network"]["private_subnet_name"] = "sl-private-subnet"
default["neutron"]["network"]["private_physical_network_name"] = "slprivate1"

default["neutron"]["network"]["softlayer_private_network_cidr"] = "10.0.0.0/8"
default["neutron"]["network"]["public_nameserver_1"] = "8.8.8.8"
default["neutron"]["network"]["public_nameserver_2"] = "8.8.4.4"
default["neutron"]["network"]["private_nameserver_1"] = "10.0.80.11"
default["neutron"]["network"]["private_nameserver_2"] = "10.0.80.12"
default["neutron"]["network"]["softlayer_private_portable"] = nil
default["neutron"]["network"]["softlayer_public_portable"] = nil
# if node.chef_environment == "SanJose2"
# default["neutron"]["network"]["softlayer_private_portable"] = "10.88.28.240/29"
# default["neutron"]["network"]["softlayer_public_portable"] = "198.23.73.148/30"
# end
# if node.chef_environment == "SanJose"
# default["neutron"]["network"]["softlayer_private_portable"] = "10.54.67.64/28"
# default["neutron"]["network"]["softlayer_public_portable"] = "50.97.218.16/29"
# end
# if node.chef_environment == "SanJose3"
# default["neutron"]["network"]["softlayer_private_portable"] = "10.54.17.208/29"
# default["neutron"]["network"]["softlayer_public_portable"] = "50.97.197.224/29"
# end
# if node.chef_environment == "DAL-A"
# default["neutron"]["network"]["softlayer_private_portable"] = "10.96.5.192/27"
# default["neutron"]["network"]["softlayer_public_portable"] = "174.122.15.128/28"
# end
# if node.chef_environment == "DAL-B"
# default["neutron"]["network"]["softlayer_private_portable"] = "10.96.5.224/27"
# default["neutron"]["network"]["softlayer_public_portable"] = "174.122.12.224/28"
# end

default["neutron"]["network"]["security_group_name"] = "basic-ssh-icmp"