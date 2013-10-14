SoftLayer Chef Recipes for OpenStack
====================================

Purpose
-------
A concise set of recipes meant to be used with SoftLayer hardware servers and Cloud Compute Instances (CCIs). They allow the end user to branch out as many pieces of OpenStack as is possible to be deployed on SoftLayer for testing or production.

Requirements
------------
#### Chef Server ####
Chef Server >= 11.4

#### Platforms ####
Ubuntu >= 12.04

#### Cookbooks ####
* Partial_search
* MySQL
* NTP
* Build-essential
* Openssl

Required Attributes
-------------------
These variables must be overridden through a [role](http://docs.opscode.com/essentials_roles.html "Chef Role Overrides") or [environment](http://docs.opscode.com/essentials_environments.html "Chef Environments") for each deployment.

* `[:admin][:password]` The password that is used throughout OpenStack to connect all the services together. This password is also set to the demo and reseller test accounts.
* `["network"]["public_interface"]`  The interface that is for public web access.  (Softlayer: eth1 or bond1)
* `["network"]["private_interface"]`  The interface that is for a local (backend) network access.  (Softlayer: eth0 or bond0)
* `["quantum"]["db"]["password"]` The quantum database password. Different from the MySQL root password.
* Quantum `softlayer_private_portable` Must be included by the customer during ordering. The private portable block must also match the VLAN of the compute and quantum nodes.
* Quantum `softlayer_public_portable` Must be purchased by the customer during ordering. The public portable block must also match the VLAN of the compute and quantum nodes. The block must be at least /30 to be compatible with the current OpenStack configuration. In addition, this block is attached to the OpenStack L3 router to provide NAT to the OpenStack networks.
* `["nova"]["db"]["password"]` The nova database password. Different from the MySQL root password.
* `["glance"]["db"]["password"]` The glance database password. Different from the MySQL root password.
* `["keystone"]["db"]["password"]` The keystone database password. Different from the MySQL root password.
* `["cinder"]["db"]["password"]` The cinder database password. Different from the MySQL root password.


Attributes
----------
Configuration settings of core OpenStack services are in the `attributes/` directory. Default values can be found for Nova, Quantum, Keystone, Cinder, and Glance in their respective attribute files. In conjunction with the set\_attributes and set\_cloundnetwork recipes, all the configuration file settings are filled in based on SoftLayer hardware.

OpenStack quantum network defaults are also found in `attributes/quantum.rb` near the bottom. The portable blocks ordered must match the VLAN of the quantum and compute nodes.

For testing purposes, default values are provided for all attributes except `node["quantum"]["network"]["softlayer_private_portable"]` and `node["quantum"]["network"]["softlayer_public_portable"]`.

##### Setting up your OpenStack cloud #####
The chef recipes need to know where the services are being deployed. This is done through the set\_cloudnetwork.rb recipe and partial_search cookbook. The recipe uses a key-pair hash to associate roles with variables throughout the rest of the chef deployment. You can change the name of the roles in `attributes/default.rb`.

* `node["admin"]["cloud_network"]["roles"]` - *Only edit if you have reason to change them* Edit only the role names as the keys are referenced by other recipes and all the keys need to have an associated role.

### Nova ###
* `node["nova"]["debug"]` - Set debug mode for nova services
* `node["nova"]["verbose"]` - Set verbose logging mode for nova services

* `node["nova"]["db"]["name"]` - Name of database for nova
* `node["nova"]["db"]["username"]` - Database username for nova db access
* `node["nova"]["db"]["password"]` - Database password for nova db user

* `node["nova"]["config"]["cpu_allocation_ratio"]` - Overprovisioning factor for virtual CPU allocation
* `node["nova"]["config"]["ram_allocation_ratio"]` - Overprovisioning factor for RAM allocation
* `node["nova"]["config"]["disk_allocation_ratio"]` - Overprovisioning factor disk allocation

* `node["nova"]["config"]["force_config_drive"]` - Set to use config_drive for instance metadata. (Default: true)
* `node["nova"]["config"]["novnc_enable"]` - Set to enable access to the noVNC console for instances.

### Quantum ###
* `node["quantum"]["config"]["debug"]` - Set debug mode for quantum services
* `node["quantum"]["config"]["verbose"]` - Set verbose logging mode for quantum services

* `node["quantum"]["db"]["name"]` - Name of database for quantum
* `node["quantum"]["db"]["username"]` - Database username for quantum db access
* `node["quantum"]["db"]["password"]` - Database password for quantum db user

* `node["quantum"]["service_tenant_name"]` - Keystone tenant name for quantum
* `node["quantum"]["service_user"]` - Keystone user name for quantum

* `node["quantum"]["config"]["bind_host"]` - IP to listen on (default 0.0.0.0)
* `node["quantum"]["config"]["bind_port"]` - Port to listen on (default 9696)

* `node["quantum"]["config"]["quota_network"]` - Per tenant allotment of creatable OpenStack networks
* `node["quantum"]["config"]["quota_subnet"]` - Per tenant allotment of creatable subnets
* `node["quantum"]["config"]["quota_port"]` - Per tenant allotment of ports. Ports are devices which are connected to a network (e.g., router, dhcp, instances).
* `node["quantum"]["config"]["quota_security_group"]` - Per tenant allotment of creatable security groups.
* `node["quantum"]["config"]["quota_security_group_rule"]` - Per tenant allotment of creatable security rules per group.

* `node["quantum"]["dhcp_agent"]["enable_isolated_metadata"]` - Allow metadata to be connected to isolated networks (e.g., No L3 router attached).

* `node["quantum"]["metadata_agent"]["metadata_proxy_shared_secret"]` - Password for metadata access between OpenStack services.

#### Quantum Network Setup ####
It is not recommended to change the physical network configuration unless you have some experience with OpenStack. These networks are specifically configured for SoftLayer hardware and CCIs. You may change other network names without causing any problems.

###### OpenStack GRE Network ######
* `node["quantum"]["network"]["openstack_network_name"]` - Name for the OpenStack network that is connected to the primary public router
* `node["quantum"]["network"]["openstack_subnet_name"]` - Name for the associated subnet
* `node["quantum"]["network"]["openstack_network_cidr"]` - CIDR network notation of the network.

###### SoftLayer Public Network ######
* `node["quantum"]["network"]["public_l3_router_name"]` - Name for the router which will be attached to the external public network.
* `node["quantum"]["network"]["public_network_name"]` - Name for the external network. This network is bridged with the public interface.
* `node["quantum"]["network"]["public_subnet_name"]` - Name for the associated subnet
* `node["quantum"]["network"]["public_physical_network_name"]` - Name of the defined interface associated with a physical network. Be careful changing this.

###### SoftLayer Private Network ######
* `node["quantum"]["network"]["private_network_name"]` - Name of the private SoftLayer network. This network is connected to the private interface bridge.
* `node["quantum"]["network"]["private_subnet_name"]` - Name of the associated subnet
* `node["quantum"]["network"]["private_physical_network_name"]` - Name of the defined interface associated with a physical network. Be careful changing this.

###### IP Configuration ######
* `node["quantum"]["network"]["softlayer_private_network_cidr"]` - SoftLayer's private network routing network
* `node["quantum"]["network"]["public_nameserver_1"]` - Publicly accessible name server 1
* `node["quantum"]["network"]["public_nameserver_2"]` - Publicly accessible name server 2
* `node["quantum"]["network"]["private_nameserver_1"]` - Privately accessible name server 1
* `node["quantum"]["network"]["private_nameserver_2"]` - Privately accessible name server 2
* `node["quantum"]["network"]["softlayer_private_portable"]` - Purchased block from SoftLayer of private IPs
* `node["quantum"]["network"]["softlayer_public_portable"]` - Purchased block from SoftLayer of public IPs


### Cinder ###
* `node["cinder"]["db"]["name"]` - Name of database for cinder
* `node["cinder"]["db"]["username"]` - Database username for cinder db access
* `node["cinder"]["db"]["password"]` - Database password for cinder db user

* `node["cinder"]["service_tenant_name"]` - Keystone tenant name for cinder
* `node["cinder"]["service_user"]` - Keystone user name for cinder

* `node["cinder"]["config"]["lvm_disk"]` - Disk to use for volume storage.
* `node["cinder"]["config"]["volume_group"]` - Name of the volume group for cinder storage

### Glance ###
* `node["glance"]["config"]["debug"]` - Set debug mode for glance services
* `node["glance"]["config"]["verbose"]` - Set verbose logging mode for glance services

* `node["glance"]["db"]["name"]` - Name of database for glance
* `node["glance"]["db"]["username"]` - Database username for glance db access
* `node["glance"]["db"]["password"]` - Database password for the glance db user

* `node["glance"]["service_tenant_name"]` - Keystone tenant name for glance
* `node["glance"]["service_user"]` - Keystone user name for glance

* `node["glance"]["config"]["bind_host"]["api"]` - API IP to listen on (default 0.0.0.0)
* `node["glance"]["config"]["bind_port"]["api"]` - API Port to listen on (default 9292)
* `node["glance"]["config"]["bind_host"]["registry"]` - Registry IP to listen on (default 0.0.0.0)
* `node["glance"]["config"]["bind_port"]["registry"]` - Registry Port to listen on (default 9292)

* `node["glance"]["config"]["workers"]` - Number of glance API workers to stand up.

###### Default Images to Load ######

* `node["glance"]["glance_repo_base_url"]` - String for the base URL where images are located.
* `node["glance"]["images"]` - Hash of `name` and `image` key-pairs that glance will download upon installation:

	    {
	        "CirrOS 0.3.0 i386" => "cirros-0.3.0-i386-disk.img",
	        "CirrOS 0.3.0 x86_64" => "cirros-0.3.0-x86_64-disk.img"
	    }


### Keystone ###
* `node["keystone"]["config"]["debug"]` - Set debug mode for keystone services
* `node["keystone"]["config"]["verbose"]` - Set verbose logging mode for keystone services

* `node["keystone"]["db"]["name"]` - Name of database for keystone
* `node["keystone"]["db"]["username"]` - Database username for keystone db access
* `node["keystone"]["db"]["password"]` - Database password for the keystone db user

* `node["keystone"]["service_tenant_name"]` - Keystone tenant name for keystone
* `node["keystone"]["service_user"]` - Keystone user name for keystone

* `node["keystone"]["config"]["bind_host"]` - IP to listen on (default 0.0.0.0)
* `node["keystone"]["config"]["public_port"]` - Public port to listen on (default 5000)
* `node["keystone"]["config"]["admin_port"]` - Admin port to listen on (default 35357)

* `node["keystone"]["region_servers"]` - Horizon can be populated with your other OpenStack clusters.  To do so add keypairs of the region names and their respective IP address location.  

		 	{"region_name" => "XX.XX.XX.XX", "region_name_2" => "XX.XX.XX.YY"}


###### Default Accounts ######
The default accounts are configured based on the OpenStack truck documentation. Feel free to change them to your needs. The admin, nova, quantum, cinder, and glance user and service objects should be created for a proper installation, though.

* `node["keystone"]["default_accounts"]["users"]` - A hash of hashes that contains the username with its corrisponding email and password info.

		{"admin" => {"email" => "root@localhost", "password" => "passwordsf" } }

* `node["keystone"]["default_accounts"]["tenants"]` - An array with the names of the tenants to be created.

* `node["keystone"]["default_accounts"]["roles"]` - An array with the names of the roles to be created.

* `node["keystone"]["default_accounts"]["services"]` - A hash of hashes that contains the service name with its type and description.

		{"nova" => {"type" => "compute", "description" => "OpenStack Compute Service" } }

* `node["keystone"]["default_accounts"]["user-roles"]` - An array of hashes for each user-tenant-role definition to be created.

		{"role" => "admin", "user" => "admin", "tenant" => "admin" },

Node Preparation
----------------
###### Cinder ######
By default cinder will use /dev/sdb as the storage device. It is strongly recommended you have a second disk partition for cinder. You can override this variable to any other device (including a [loop device](http://en.wikipedia.org/wiki/Loop_device "loop device") for testing). The chef recipes will check for the volume group name of the LUN, and if it isn't present it will repartition the drive and format it for Cinder. All data will be ERASED if the recipe finds the disk but does not find the volume group associated with it.

Bootstrapping
-------------

All the roles must be assigned to a server. Compute and network roles can be assigned to multiple servers based on your requirements.

	grizzly-controller
	grizzly-network
	grizzly-rabbitmq
	grizzly-keystone
	grizzly-glance
	grizzly-cinder
	grizzly-compute
	grizzly-mysql-all
	[or]
	grizzly-mysql-glance
	grizzly-mysql-cinder
	grizzly-mysql-keystone
	grizzly-mysql-nova
	grizzly-mysql-quantum

The bootstrap directory contains an example script for calling chef to clear, boostrap, and assign roles to chef nodes. Verify that the environments roles were set correctly.

MySQL: When running `chef-client` on each node, it is important to put the mysql installs before the rest of the roles as many of the roles depend on it to be ready for database preparation.

### Roles ###

Roles must be uploaded using `knife upload from file roles/{grizzly-controller.json}`. They are not included in the cookbook upload and must be uploaded manually per chef server instructions.

At a minimum the MySQL backend(s), controller, network, glance, keystone, and cinder node roles must be assigned for `set_cloudnetwork.rb` to correctly find all values needed. Additional compute and network nodes can be added by deploying the compute and network roles to additional hardware.

### MySQL Backend ###

The OpenStack services are now separated into frontend (e.g., glance) and backend (e.g., Glance's MySQL server). The roles are setup so that all backends can be run from one node, all independently, or any combination thereof.

###### MySQL ######
MySQL can be deployed as a separate install per OpenStack service or all databases on one node. You can optionally use the grizzly-mysql-all role for deploying all databases to the same node.

For example:

Node 1:

	grizzly-controller
	grizzly-keystone
	grizzly-mysql-keystone
	grizzly-mysql-nova
	grizzly-mysql-quantum

Node 2:

	grizzly-glance
	grizzly-mysql-glance

Node 3:

	grizzly-cinder
	grizzly-mysql-cinder

Node 4:

	grizzly-compute

Node 5:

	grizzly-network

On a large scale deployment, this would ease the load on any given mysql server instance by separating the services that use them.

### OpenStack Regions ###

Each compute cluster can have unlimited regions associated with it. This is implemented through Chef Environments. OpenStack installs are isolated through the use of environment names and horizon is populated with the keystone information for each region (environment), allowing the user to choose a region from horizon at login. If new regions are added the dashboard recipe will need to be rerun on every controller node to repopulate the keystone server information in horizon.

Configure Chef Overrides for OpenStack
--------------------------------------
You will need to override some attributes for your OpenStack Chef deployment. These can be overridden at the environment level or at the node level, but the environmental level is strongly recommended.

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
	    "quantum": {
	      "db": {
	        "password": "my_new_quantum_pass"
	      },
	      "softlayer_public_portable": "XX.XX.XX.XX/YY",
	      "softlayer_private_portable": "AA.AA.AA.AA/BB"
	    },
	    "nova": {
	      "db": {
	        "password": "my_new_nova_pass"
	      }
	    },
	    "glance": {
	      "db": {
	        "password": "my_new_glance_pass"
	      }
	    },
	    "keystone": {
	      "db": {
	        "password": "my_new_keystone_pass"
	      }
	    },
	    "cinder": {
	      "db": {
	        "password": "my_new_cinder_pass"
	      }
	    }
	  }
	}


Installation Overview
---------------------
The instructions below provide a general overview of steps you will perform to install an OpenStack environment with SoftLayer Private Cloud. It demonstrates a typical OpenStack installation, and includes additional information about customizing or modifying your installation. Generally, your installation will follow these steps, with more details outlined in the other sections below.

1.  Configure a bootstrap script with the hardware servers and/or cloud compute instances (CCIs) that you wish to bootstrap with Chef. Ensure you substitute the proper FQDN/IP, user account with sudo access, the path to that user's private key to log in to the server, as well as the Chef Server environment in which the node resides. In this example, these are represented with FQDN_or_IP, USER, and ENVIRONMENT, respectively.

		knife bootstrap FQDN_or_IP -x USER --sudo -i /home/USER/id_rsa -E ENVIRONMENT

2.  Edit the role information for each server and role. In this case, since Chef Server will know the FQDN of each node, you can simply use the FQDN rather than providing an IP as you may have done in step 1.

		knife node run_list add FQDN 'role[grizzly-controller]'

3.  Run the bootstrap script you've just created to prepare each server with the `chef-client` utility.

4.  The `chef-client` program will need to be run on each server to start the installation. Run the installs in this order:
	* MySQL roles
	* RabbitMQ
	* Keystone
	* Controller
	* Any remaining roles

Step-by-step Install
--------------------
### Install Chef Server ###
This installation is not outlined here. Please follow an installation guide for chef server. One can be located here: http://docs.opscode.com/install_server.html.

### Bootstrap the clients ###
There are two choices when bootstrapping nodes. SoftLayer has provided example scripts, which can be edited for your needs, or you can bootstrap them on your own by following a chef-client install guide or installing chef-client on your own. It is recommended to use the bootstrap scripts.

Edit the script with each hardware node you would like to include in the OpenStack installation. It is highly recommended that at least three nodes be used—one for a controller, one for a network node, and one for a compute node. After the bootstrap process completes, the script will assign an OpenStack role to the hardware nodes. A node can have more than one role. A three-node bootstrap example script is shown below.

	#!/bin/bash
	
	## Bootstrap three nodes with chef-client, registering them with Chef Server
	knife bootstrap FQDN_or_IP_1 -x USER --sudo -i /home/USER/.ssh/id_rsa -E ENVIRONMENT
	knife bootstrap FQDN_or_IP_2 -x USER --sudo -i /home/USER/.ssh/id_rsa -E ENVIRONMENT
	knife bootstrap FQDN_or_IP_3 -x USER --sudo -i /home/USER/.ssh/id_rsa -E ENVIRONMENT
	
	## Now, add specific roles to each node's run list that will run once `chef-client` is run
	## Controller node:
	knife node run_list add FQDN_1 'role[grizzly-mysql-cinder]'
	knife node run_list add FQDN_1 'role[grizzly-mysql-glance]'
	knife node run_list add FQDN_1 'role[grizzly-mysql-keystone]'
	knife node run_list add FQDN_1 'role[grizzly-mysql-nova]'
	knife node run_list add FQDN_1 'role[grizzly-mysql-quantum]'
	knife node run_list add FQDN_1 'role[grizzly-rabbitmq]'
	knife node run_list add FQDN_1 'role[grizzly-cinder]'
	knife node run_list add FQDN_1 'role[grizzly-keystone]'
	knife node run_list add FQDN_1 'role[grizzly-glance]'
	knife node run_list add FQDN_1 'role[grizzly-controller]'
	
	## Compute node:
	knife node run_list add FQDN_2 'role[grizzly-compute]'
	
	## Network node:
	knife node run_list add FQDN_3 'role[grizzly-network]'

### Chef the mysql-backend node(s) and rabbit node ###
If you have chosen to make the MySQL node(s) separate from the controller, you must first complete a deployment of the MySQL roles prior to chefing the controller node with any OpenStack services. You may easily deploy MySQL roles for each OpenStack component by adding your additional nodes to the sample script above and specifying which MySQL role(s) to apply to each.

Similarly, if you intend to deploy RabbitMQ on a separate server, you may follow the same process, but deploying the RabbitMQ role must be performed prior to chefing the controller with any OpenStack services. It is independent of the MySQL roles.

Otherwise, please skip to the next step if MySQL and RabbitMQ will run from your controller node.

### Chef the controller node ###
The controller node contains, at a minimum, the roles for the base Quantum and Nova services. If you are unfamiliar with OpenStack, it is recommended to do a standard installation as illustrated in the bootstrap example. Be sure that Chef shows that the node contains the MySQL backends, RabbitMQ, Keystone, Cinder, and Glance roles. You can verify this with a simple knife command:
	
	knife node show FQDN

To chef the controller node you can either connect directly to the remote server and (with root privileges) run `chef-client` from the node itself or use [knife ssh](http://docs.opscode.com/knife_ssh.html "Opscode Knife SSH") to run it from the Chef server:

	knife ssh SEARCH 'sudo chef-client'
For example:

	knife ssh 'role:grizzly-controller' 'sudo chef-client'
or

	knife ssh 'name:FQDN' 'sudo chef-client'

### Chef the remaining nodes ###
After the MySQL, RabbitMQ, and controller roles have been chefed, any of the remaining roles can then be run in any order for the other nodes, and can even be run in parallel to speed up your total deployment time. Following the example above, the two commands would chef your network and compute nodes:

	## Compute node:
	knife ssh 'name:FQDN_2' 'sudo chef-client'
	
	## Network node:
	knife ssh 'name:FQDN_3' 'sudo chef-client'

### Verify Installation ###
Run the following commands on the controller to check if OpenStack has been deployed and is running correctly:

Run `source ~/.openrc` to update your environment with access to the openstack CLI. The .openrc file is located at /root/.openrc.

You may wish to add `source .openrc` to your `.bash_profile` file so that the CLI variables are set each time you log in:

	root@FQDN1:~# echo "source ~/.openrc" >> ~/.bash_profile


	root@FQDN1:~# nova-manage service list
	Binary           Host                                 Zone             Status     State Updated_At
	nova-cert        FQDN_1			                      internal         enabled    :-)   2013-09-17 15:21:29
	nova-scheduler   FQDN_1              		          internal         enabled    :-)   2013-09-17 15:21:29
	nova-conductor   FQDN_1                      		  internal         enabled    :-)   2013-09-17 15:21:29
	nova-consoleauth FQDN_1      		                  internal         enabled    :-)   2013-09-17 15:21:30
	nova-compute     FQDN_2                			      nova             enabled    :-)   2013-09-17 15:21:23

	root@FQDN1:~# quantum agent-list
	+--------------------------------------+--------------------+---------------------------+-------+----------------+
	| id                                   | agent_type         | host                      | alive | admin_state_up |
	+--------------------------------------+--------------------+---------------------------+-------+----------------+
	| 438d2dd2-daf3-496c-99ad-179ed307b8d6 | Open vSwitch agent | FQDN_2 					| :-)   | True           |
	| 4c684b66-16db-4853-8cb3-51098c3752b3 | L3 agent           | FQDN_3 					| :-)   | True           |
	| 98c3d818-0ebe-4cd6-89bf-0f107a7532ab | DHCP agent         | FQDN_3 					| :-)   | True           |
	| dd3b9134-ab76-440a-ba7a-70135202eb82 | Open vSwitch agent | FQDN_3 					| :-)   | True           |
	+--------------------------------------+--------------------+---------------------------+-------+----------------+

Services will have a `:-)` if they are working correctly and `XX` if they are not.

Author
------

Paul Sroufe ([psroufe@softlayer.com](mailto:psroufe@softlayer.com "Paul Sroufe"))