
Required Attributes
-------------------
These attributes must be overridden through a an [environment](http://docs.opscode.com/essentials_environments.html "Chef Environments") for each deployment.

* `['admin']['password']` - The password that is used throughout OpenStack to connect all the services together. This password is also applied on the demo and reseller test accounts.
* `['network']['private_interface']` - The interface that is for a local (backend) network access. (SoftLayer default: eth0 or bond0)
* `['network']['public_interface']` - The public network interface where API requests and the dashboard are accessible (SoftLayer default: eth1 or bond1)
* `['neutron']['softlayer_private_portable']` - Must be included by the customer during ordering, and must be routed to the same VLAN as the compute and network nodes.
* `['neutron']['softlayer_public_portable']` - Must be purchased by the customer during ordering, and must be routed to the same VLAN as the compute and network nodes. This block is attached to the OpenStack L3 router to provide NAT to Neutron networks connected to the public router. Must be at least a /30 to be compatible with the current OpenStack configuration.
* `['neutron']['db']['password']` - The Neutron database password (different from the MySQL root password)
* `['nova']['db']['password']` - The Nova database password (different from the MySQL root password)
* `['glance']['db']['password']` - The Glance database password (different from the MySQL root password)
* `['keystone']['db']['password']` - The Keystone database password (different from the MySQL root password)
* `['cinder']['db']['password']` - The Cinder database password (different from the MySQL root password)


Additional Attributes
---------------------
Configuration settings of core OpenStack services are in the `attributes/` directory. Default values can be found for Nova, Neutron, Keystone, Cinder, and Glance in their respective attribute files. In conjunction with the set\_attributes and set\_cloundnetwork recipes, all the configuration file settings are filled in based on SoftLayer hardware.

OpenStack neutron network defaults are also found in `attributes/neutron.rb` near the bottom. The portable blocks ordered must match the VLAN of the neutron and compute nodes.

For testing purposes, default values are provided for all attributes except `node['neutron']['network']['softlayer_private_portable']` and `node['neutron']['network']['softlayer_public_portable']`.

##### Setting up your OpenStack cloud #####
The chef recipes need to know where the services are being deployed. This is done through the set\_cloudnetwork.rb recipe and partial_search cookbook. The recipe uses a key-pair hash to associate roles with variables throughout the rest of the chef deployment. You can change the name of the roles in `attributes/default.rb`.

* `node['admin']['cloud_network']['roles']` - (*Only edit if you have reason to change them*) Edit only the role names as the keys are referenced by other recipes and all the keys need to have an associated role.

### Nova ###
* `node['nova']['debug']` - Set debug mode for Nova services
* `node['nova']['verbose']` - Set verbose logging mode for Nova services

* `node['nova']['db']['name']` - Name of Nova database
* `node['nova']['db']['username']` - Database username for Nova
* `node['nova']['db']['password']` - Database password for Nova

* `node['nova']['config']['cpu_allocation_ratio']` - Overprovisioning factor for virtual CPU allocation
* `node['nova']['config']['ram_allocation_ratio']` - Overprovisioning factor for RAM allocation
* `node['nova']['config']['disk_allocation_ratio']` - Overprovisioning factor disk allocation

* `node['nova']['config']['force_config_drive']` - Set to use a config drive for instance metadata (Default: true)
* `node['nova']['config']['novnc_enable']` - Set to enable access to the noVNC console for instances

### Neutron ###
* `node['neutron']['config']['debug']` - Set debug mode for Neutron services
* `node['neutron']['config']['verbose']` - Set verbose logging mode for Neutron services

* `node['neutron']['db']['name']` - Name of Neutron database
* `node['neutron']['db']['username']` - Database username for Neutron
* `node['neutron']['db']['password']` - Database password for Neutron

* `node['neutron']['service_tenant_name']` - Keystone tenant name for Neutron services
* `node['neutron']['service_user']` - Keystone user name for Neutron services

* `node['neutron']['config']['bind_host']` - IP to listen on (default: 0.0.0.0)
* `node['neutron']['config']['bind_port']` - Port to listen on (default: 9696)

* `node['neutron']['config']['quota_network']` - Maximum Neutron networks each tenant can create
* `node['neutron']['config']['quota_subnet']` - Maximum Neutron subnets each tenant can create
* `node['neutron']['config']['quota_port']` - Maximum number of Neutron ports each tenant can create. Ports mimic switch ports in that they connect various devices on a Neutron network (e.g., routers, load balancers, DHCP servers, instances).
* `node['neutron']['config']['quota_security_group']` - Maximum number of security groups each tenant can create
* `node['neutron']['config']['quota_security_group_rule']` - Maximum number of security group rules each tenant can create

* `node['neutron']['dhcp_agent']['enable_isolated_metadata']` - Allow metadata to be connected to isolated networks (e.g., when no L3 router attached)

* `node['neutron']['metadata_agent']['metadata_proxy_shared_secret']` - Password for metadata exchange between Neutron's metadata proxy and Nova's metadata service

#### Neutron Network Setup ####
It is not recommended to change the physical network configuration unless you have some experience with OpenStack. These networks are specifically configured for SoftLayer hardware and CCIs. You may change other network names without causing any problems.

###### OpenStack GRE Network ######
* `node['neutron']['network']['openstack_network_name']` - Name for the OpenStack GRE network connected to Neutron's primary public router
* `node['neutron']['network']['openstack_subnet_name']` - Name for the associated subnet
* `node['neutron']['network']['openstack_network_cidr']` - CIDR mask of the associated subnet

###### SoftLayer Public Network ######
* `node['neutron']['network']['public_l3_router_name']` - Name for the primary public router which will be attached to the external public network
* `node['neutron']['network']['public_network_name']` - Name for the external network. This network connected to the public interface bridge.
* `node['neutron']['network']['public_subnet_name']` - Name for the associated subnet
* `node['neutron']['network']['public_physical_network_name']` - Name for the interface associated with the public physical network. Be careful changing this.

###### SoftLayer Private Network ######
* `node['neutron']['network']['private_network_name']` - Name for the private SoftLayer network. This network is connected to the private interface bridge.
* `node['neutron']['network']['private_subnet_name']` - Name for the associated subnet
* `node['neutron']['network']['private_physical_network_name']` - Name for the interface associated with the private physical network. Be careful changing this.

###### IP Configuration ######
* `node['neutron']['network']['softlayer_private_network_cidr']` - CIDR mask of SoftLayer's private network (default: 10.0.0.0/8) It is not recommended to change this as it may make the SoftLayer private network unreachable from your instances.
* `node['neutron']['network']['public_nameserver_1']` - Publicly accessible name server 1
* `node['neutron']['network']['public_nameserver_2']` - Publicly accessible name server 2
* `node['neutron']['network']['private_nameserver_1']` - Private network name server 1
* `node['neutron']['network']['private_nameserver_2']` - Private network name server 2
* `node['neutron']['softlayer_private_portable']` - CIDR mask of portable private IP block ordered from SoftLayer
* `node['neutron']['softlayer_public_portable']` - CIDR mask of portable public IP block ordered from SoftLayer


### Cinder ###
* `node['cinder']['db']['name']` - Name of Cinder database
* `node['cinder']['db']['username']` - Database username for Cinder
* `node['cinder']['db']['password']` - Database password for Cinder

* `node['cinder']['service_tenant_name']` - Keystone tenant name for Cinder services
* `node['cinder']['service_user']` - Keystone user name for Cinder services

* `node['cinder']['config']['lvm_disk']` - Physical disk to use for LVM-based volume storage
* `node['cinder']['config']['volume_group']` - Name of the LVM volume group for Cinder volume storage

### Glance ###
* `node['glance']['config']['debug']` - Set debug mode for Glance services
* `node['glance']['config']['verbose']` - Set verbose logging mode for Glance services

* `node['glance']['db']['name']` - Name of Glance database
* `node['glance']['db']['username']` - Database username for Glance
* `node['glance']['db']['password']` - Database password for Glance

* `node['glance']['service_tenant_name']` - Keystone tenant name for Glance services
* `node['glance']['service_user']` - Keystone user name for Glance services

* `node['glance']['config']['bind_host']['api']` - API IP to listen on (default: 0.0.0.0)
* `node['glance']['config']['bind_port']['api']` - API Port to listen on (default: 9292)
* `node['glance']['config']['bind_host']['registry']` - Registry IP to listen on (default: 0.0.0.0)
* `node['glance']['config']['bind_port']['registry']` - Registry Port to listen on (default: 9292)

* `node['glance']['config']['workers']` - Number of Glance API workers to stand up

###### Default Images to Load ######

* `node['glance']['glance_repo_base_url']` - String for the base URL where images are located
* `node['glance']['images']` - Hash of `name` and `image` pairs that Glance will download after installation:

        {
            "CirrOS 0.3.0 i386" => "cirros-0.3.0-i386-disk.img",
            "CirrOS 0.3.0 x86_64" => "cirros-0.3.0-x86_64-disk.img"
        }


### Keystone ###
* `node['keystone']['apache_frontend']` - Run Keystone under Apache's mod_wsgi to allow for more concurrent connections (default: true)
* `node['keystone']['config']['debug']` - Set debug mode for Keystone services
* `node['keystone']['config']['verbose']` - Set verbose logging mode for Keystone services

* `node['keystone']['db']['name']` - Name of database for Keystone
* `node['keystone']['db']['username']` - Database username for Keystone
* `node['keystone']['db']['password']` - Database password for Keystone

* `node['keystone']['service_tenant_name']` - Keystone tenant name for Keystone services
* `node['keystone']['service_user']` - Keystone user name for Keystone services

* `node['keystone']['config']['bind_host']` - IP to listen on (default: 0.0.0.0)
* `node['keystone']['config']['public_port']` - Public port to listen on (default: 5000)
* `node['keystone']['config']['admin_port']` - Admin port to listen on (default: 35357)

* `node['keystone']['region_servers']` - Horizon can be populated with your other OpenStack clusters.  To do so add keypairs of the region names and their respective IP address location:

        { "region_name" => "XX.XX.XX.XX", "region_name_2" => "XX.XX.XX.YY"}


###### Default Accounts ######
The default accounts are configured based on the OpenStack trunk documentation. Feel free to change them, however the admin, nova, neutron, cinder, and glance user and service user accounts should be created for a proper installation.

* `node['keystone']['default_accounts']['users']` - A hash of hashes that contains the username with its corrisponding email and password info:

        { "admin" => {"email" => "root@localhost", "password" => "passwordsf" } }

* `node['keystone']['default_accounts']['tenants']` - An array with tenant names to create

* `node['keystone']['default_accounts']['roles']` - An array with role names to create

* `node['keystone']['default_accounts']['services']` - A hash of hashes each service's name with its type and description:

        { "nova" => {"type" => "compute", "description" => "OpenStack Compute Service" } }

* `node['keystone']['default_accounts']['user-roles']` - An array of hashes with each user-tenant-role definition to create:

        { "role" => "admin", "user" => "admin", "tenant" => "admin" },