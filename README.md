SoftLayer Chef Recipes for OpenStack
====================================

Purpose
-------
These are a concise set of recipes meant to be used with SoftLayer hardware servers and Cloud Compute Instances (CCIs). They allow deployers to scale or branch out as many pieces of OpenStack infrastructure as is possible to be deployed on SoftLayer for testing or production.

Requirements
------------
#### Chef Server ####
Chef Server >= 11.4

#### Platforms ####
Ubuntu 12.04 LTS

#### Cookbooks ####
* Partial_search
* MySQL
* NTP
* Build-essential
* Openssl

Required Attributes
-------------------
These attributes must be overridden through a [role](http://docs.opscode.com/essentials_roles.html "Chef Role Overrides") or [environment](http://docs.opscode.com/essentials_environments.html "Chef Environments") for each deployment.

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
* `node['neutron']['network']['softlayer_private_portable']` - CIDR mask of portable private IP block ordered from SoftLayer
* `node['neutron']['network']['softlayer_public_portable']` - CIDR mask of portable public IP block ordered from SoftLayer


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
* `node['keystone']['config']['debug']` - Set debug mode for Keystone services
* `node['keystone']['config']['verbose']` - Set verbose logging mode for Keystone services

* `node['keystone']['db']['name']` - Name of database for Keystone
* `node['keystone']['db']['username']` - Database username for Keystone
* `node['keystone']['db']['password']` - Database password for Keystone

* `node['keystone']['service_tenant_name']` - Keystone tenant name for Keystone services
* `node['keystone']['service_user']` - Keystone user name for Keystone services

* `node['keystone']['config']['bind_host']` - IP to listen on (default 0.0.0.0)
* `node['keystone']['config']['public_port']` - Public port to listen on (default 5000)
* `node['keystone']['config']['admin_port']` - Admin port to listen on (default 35357)

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

Node Preparation
----------------
###### Cinder ######
By default, Cinder will use `/dev/sdb` as the storage device. It is strongly recommended you have a second disk partition for Cinder. You can override this variable with the path to any other device (including a [loop device](http://en.wikipedia.org/wiki/Loop_device "loop device") for testing, such as `/dev/lo0`). The Cinder recipe will check for the volume group name of the LUN, and if it isn't present it will repartition the drive and format it for Cinder. **All data will be ERASED** if the recipe finds the disk but does not find the volume group associated with it.

Bootstrapping
-------------

All roles must be assigned to a server. Compute and network roles can be assigned to multiple servers based on your requirements:

    openstack-mysql-all
    openstack-rabbitmq
    openstack-keystone
    openstack-controller
    openstack-glance
    openstack-cinder
    openstack-network
    openstack-compute

Additionally, instead of using the `openstack-mysql-all` role, you can specify individual MySQL roles:

    openstack-mysql-glance
    openstack-mysql-cinder
    openstack-mysql-keystone
    openstack-mysql-nova
    openstack-mysql-neutron

The bootstrap directory contains an example script that uses Chef to clear, boostrap, and assign roles to individual nodes. Once finished, verify that the environments roles were set correctly.

MySQL note: When running `chef-client` on each node, it is important to run all MySQL installs before the rest of the roles, since many of the roles depend on it to be ready for database preparation.

### Roles ###

Roles must be uploaded using `knife upload from file roles/{openstack-controller.json}`. They are not included in the cookbook upload and must be uploaded manually per Chef Server instructions.

At a minimum, the MySQL, controller, network, glance, keystone, and cinder roles **must** be assigned for `set_cloudnetwork.rb` to correctly find all values needed. Additional compute and network nodes can be added by deploying the compute and network roles to additional hardware.

### MySQL Backend ###

The OpenStack services are now separated into frontend (e.g., Glance) and backend (e.g., Glance's MySQL server). The roles are designed to allow all databases to be run from one node, each independently, or any combination thereof.

###### MySQL ######
MySQL can be deployed as a separate install per OpenStack service or all databases on one node. You can optionally use the `openstack-mysql-all` role to deploy all databases to the same node.

For example, in a five-node setup, you could physically separate your Glance and Cinder databases:

Node 1:

    openstack-controller
    openstack-keystone
    openstack-mysql-keystone
    openstack-mysql-nova
    openstack-mysql-neutron

Node 2:

    openstack-glance
    openstack-mysql-glance

Node 3:

    openstack-cinder
    openstack-mysql-cinder

Node 4:

    openstack-compute

Node 5:

    openstack-network

In a large-scale deployment, this would alleviate some load on any given MySQL server instance as a result of physical separation.

### OpenStack Regions ###

Each OpenStack cluster can have unlimited regions associated with it; this is implemented through Chef Environments. OpenStack clusters are isolated through the use of Chef environment names and OpenStack region names, and the Horizon dashboard configuration is populated with the Keystone authentication endpoint for each region (environment), allowing end-users to choose a region at login. Each time additional regions are added, the dashboard recipe will need to be re-run on every controller node to repopulate the Keystone server information in Horizon.

Configure Chef Overrides for OpenStack
--------------------------------------
You are required to override some attributes for your OpenStack Chef deployment. These can be overridden at the environment level or at the node level, but the environmental level is strongly recommended.

Edit your environment with the following command (you may also edit this from the Chef web-based UI). An editor will open where you may define your environment's attributes in JSON format.

    knife environment edit ENVIRONMENT (options)

Take special care to ensure your final environment document is valid JSON, as knife may discard your attempted change if the JSON does not properly validate once you save and exit the editor.

The following is an example of some attributes that can be overridden in the environment, illustrating the required attributes to deploy:

    "override_attributes": {
        "admin": {
            "password": "admin_pass"
        },
        "network": {
            "public_interface": "eth1",
            "private_interface": "eth0"
        },
        "neutron": {
            "db": {
                "password": "my_neutron_pass"
            },
            "softlayer_public_portable": "XX.XX.XX.XX/YY",
            "softlayer_private_portable": "AA.AA.AA.AA/BB"
        },
        "nova": {
            "db": {
                "password": "my_nova_pass"
            }
        },
        "glance": {
            "db": {
                "password": "my_glance_pass"
            }
        },
        "keystone": {
            "db": {
                "password": "my_keystone_pass"
            }
        },
        "cinder": {
            "db": {
                "password": "my_cinder_pass"
            }
        }
    }


Installation Overview
---------------------
The instructions below provide a general overview of steps you will perform to install an OpenStack environment with SoftLayer Private Cloud. It demonstrates a typical OpenStack installation, and includes additional information about customizing or modifying your installation. Generally, your installation will follow these steps, with more details outlined in the other sections below.

1.  Configure a bootstrap script with the hardware servers and/or cloud compute instances (CCIs) that you wish to bootstrap with Chef. Ensure you substitute the proper FQDN/IP, user account with sudo access, the path to that user's private key to log in to the server, as well as the Chef Server environment in which the node resides. In this example, these are represented with FQDN, USER, and ENVIRONMENT, respectively.

        knife bootstrap FQDN -x USER --sudo -i /home/USER/id_rsa -E ENVIRONMENT

2.  Edit the role information for each server and role. In this case, since Chef Server will know the FQDN of each node, you can simply use the FQDN rather than providing an IP as you may have done in step 1.

        knife node run_list add FQDN 'role[openstack-controller]'

3.  Run the bootstrap script you've just created to prepare each server with the `chef-client` utility.

4.  Run the `chef-client` program on each server to start installation. Run them in this order:
    * MySQL roles
    * RabbitMQ role
    * Keystone role
    * Controller role
    * All remaining roles

Step-by-step Install
--------------------
### Install Chef Server ###
This installation is not outlined here. Please follow the Opscode installation guide for Chef Server at http://docs.opscode.com/install_server.html.

### Bootstrap the nodes ###
There are two choices when bootstrapping nodes. SoftLayer has provided an example script that can be edited for your needs, or you can manually bootstrap them on your own by following a chef-client install guide or installing chef-client on your own. It is recommended to use the sample bootstrap script.

Edit the script with each hardware node you would like to include in the OpenStack installation. It is highly recommended that at least three nodes be used—one as the controller, one as a network node, and one as a compute node. After the bootstrap process completes, the script will assign an OpenStack role to the hardware nodes. A node can have more than one role. A three-node bootstrap example script is shown below.

    #!/bin/bash
    
    ## Bootstrap three nodes with chef-client, registering them with Chef Server
    knife bootstrap control01.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
    knife bootstrap compute01.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
    knife bootstrap network01.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
    
    ## Now, add specific roles to each node's run list that will run once `chef-client` is run
    ## Controller node:
    knife node run_list add control01.example.com 'role[openstack-mysql-all]'
    knife node run_list add control01.example.com 'role[openstack-rabbitmq]'
    knife node run_list add control01.example.com 'role[openstack-keystone]'
    knife node run_list add control01.example.com 'role[openstack-controller]'
    knife node run_list add control01.example.com 'role[openstack-cinder]'
    knife node run_list add control01.example.com 'role[openstack-glance]'
    
    ## Compute node:
    knife node run_list add compute01.example.com 'role[openstack-compute]'
    
    ## Network node:
    knife node run_list add network01.example.com 'role[openstack-network]'

### Chef the MySQL node(s) and RabbitMQ node ###
If you have chosen to make the MySQL node(s) separate from the controller, you must first complete a deployment of the MySQL roles prior to chefing the controller node with any OpenStack services. You may easily deploy MySQL roles for each OpenStack component by adding your additional nodes to the sample script above and specifying which MySQL role(s) to apply to each.

Similarly, if you intend to deploy RabbitMQ on a separate server, you may follow the same process, but deploying the RabbitMQ role must be performed prior to chefing the controller with any OpenStack services. It is independent of the MySQL roles.

Otherwise, please skip to the next step if MySQL and RabbitMQ will run from your controller node.

### Chef the controller node ###
The controller node contains, at a minimum, the roles for the base Neutron and Nova services. If you are unfamiliar with OpenStack, it is recommended to do a standard installation as illustrated in the bootstrap example. Be sure that Chef shows that the node contains the MySQL backends, RabbitMQ, Keystone, Cinder, and Glance roles. You can verify this with a simple knife command:
    
    knife node show control01.example.com

To chef the controller node you can either connect directly to the remote server and (with root privileges) run `chef-client` from the node itself or use [knife ssh](http://docs.opscode.com/knife_ssh.html "Opscode Knife SSH") to run it from the Chef server:

    knife ssh SEARCH 'sudo chef-client'

For example, to search by role:

    knife ssh 'role:openstack-controller' 'sudo chef-client'

Or, to search by hostname:

    knife ssh 'name:control01.example.com' 'sudo chef-client'

### Chef the remaining nodes ###
After the MySQL, RabbitMQ, and controller roles have been chefed, any of the remaining roles can then be run in any order for the other nodes, and can even be run in parallel to speed up your total deployment time. Following the example above, the two commands would chef your network and compute nodes:

    ## Compute node:
    knife ssh 'name:compute01.example.com' 'sudo chef-client'
    
    ## Network node:
    knife ssh 'name:network01.example.com' 'sudo chef-client'

### Verify Installation ###
Run the following commands on the controller to check if OpenStack has been deployed and is running correctly:

Run `source ~/.openrc` to update your environment so you can use the OpenStack command line tools. The .openrc file is located at /root/.openrc.

You may wish to add `source .openrc` to your `.bash_profile` file so that the CLI variables are set each time you log in:

    root@control01:~# echo "source ~/.openrc" >> ~/.bash_profile

    root@control01:~# source ~/.openrc

    root@control01:~# nova-manage service list
    Binary            Host                   Zone      Status   State  Updated_At
    nova-cert         control01.example.com  internal  enabled  :-)    2013-09-17 15:21:29
    nova-scheduler    control01.example.com  internal  enabled  :-)    2013-09-17 15:21:29
    nova-conductor    control01.example.com  internal  enabled  :-)    2013-09-17 15:21:29
    nova-consoleauth  control01.example.com  internal  enabled  :-)    2013-09-17 15:21:30
    nova-compute      compute01.example.com  nova      enabled  :-)    2013-09-17 15:21:23

    root@control01:~# neutron agent-list
    +--------------------------------------+--------------------+-----------------------+-------+----------------+
    | id                                   | agent_type         | host                  | alive | admin_state_up |
    +--------------------------------------+--------------------+-----------------------+-------+----------------+
    | 438d2dd2-daf3-496c-99ad-179ed307b8d6 | Open vSwitch agent | compute01.example.com | :-)   | True           |
    | 4c684b66-16db-4853-8cb3-51098c3752b3 | L3 agent           | network01.example.com | :-)   | True           |
    | 98c3d818-0ebe-4cd6-89bf-0f107a7532ab | DHCP agent         | network01.example.com | :-)   | True           |
    | dd3b9134-ab76-440a-ba7a-70135202eb82 | Open vSwitch agent | network01.example.com | :-)   | True           |
    +--------------------------------------+--------------------+-----------------------+-------+----------------+

Services will have a `:-)` if they are working correctly and `XX` if they are not.

Authors
-------

Paul Sroufe ([psroufe@softlayer.com](mailto:psroufe@softlayer.com "Paul Sroufe"))  
Brian Cline ([bcline@softlayer.com](mailto:bcline@softlayer.com "Brian Cline"))  
