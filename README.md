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

Chef Attributes
---------------
For Information on specific attributes please see the attributes/ directory.

Server Preparation
----------------
###### Cinder ######
By default, Cinder will use `/dev/sdb` as the storage device. It is strongly recommended you have a second disk partition for Cinder. You can override this variable with the path to any other device (including a [loop device](http://en.wikipedia.org/wiki/Loop_device "loop device") for testing, such as `/dev/lo0`). The Cinder recipe will check for the volume group name of the LUN, and if it isn't present it will repartition the drive and format it for Cinder. **All data will be ERASED** if the recipe finds the disk but does not find the volume group associated with it.

###### OpenStack Regions #######

Each OpenStack cluster can have unlimited regions associated with it; this is implemented through Chef Environments. OpenStack clusters are isolated through the use of Chef environment names and OpenStack region names, and the Horizon dashboard configuration is populated with the Keystone authentication endpoint for each region (environment), allowing end-users to choose a region at login. Each time additional regions are added, the dashboard recipe will need to be re-run on every controller server to repopulate the Keystone server information in Horizon.

Please refer to the attributes/ directory for more information.

Configure Environment Overrides for Chef-OpenStack
--------------------------------------------------
You are required to provide some attributes for your OpenStack Chef deployment. These can be overridden at the environment level or at the node level, but the environmental level is strongly recommended.

Edit your environment with the following command (you may also edit this from the Chef web-based UI). An editor will open where you may define your environment's attributes in JSON format.

	knife environment create ENVIRONMENT (options)    
	knife environment edit ENVIRONMENT (options)

Take special care to ensure your final environment document is valid JSON, as knife may discard your attempted change if the JSON does not properly validate once you save and exit the editor.

The following is an example of the minimum attributes that can be used to deploy an environment:

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

**SoftLayer public and private portable blocks are ordered separately through the SoftLayer website.**

Installation Overview
---------------------
The instructions below provide a general overview of steps you will perform to install an OpenStack environment with SoftLayer Private Cloud. It demonstrates a typical OpenStack installation, and includes additional information about customizing or modifying your installation. Generally, your installation will follow these steps, with more details outlined in the other sections below.

1.  Configure a bootstrap script with the hardware servers and/or cloud compute instances (CCIs) that you wish to bootstrap with Chef. Ensure you substitute the proper FQDN/IP, user account with sudo access, the path to that user's private key to log in to the server, as well as the Chef Server environment in which the server resides. In this example, these are represented with FQDN, USER, and ENVIRONMENT, respectively.

        knife bootstrap FQDN -x USER --sudo -i /home/USER/.ssh/id_rsa -E ENVIRONMENT

2.  Edit the role information for each server and role. In this case, since Chef Server will know the FQDN of each server, you can simply use the FQDN rather than providing an IP as you may have done in step 1.

        knife node run_list add FQDN 'recipe[chef-openstack::controller]'

3.  Run the bootstrap script you've just created to prepare each server with the `chef-client` utility.

4.  Run the `chef-client` program on each server to start installation. Servers should be chef'ed in this order:
    * MySQL recipes
    * RabbitMQ recipes
    * Keystone recipes
    * Controller recipes
    * Any remaining recipes

Step-by-step Install
--------------------
### Install Chef Server ###
This installation is not outlined here. Please follow the Opscode installation guide for Chef Server at http://docs.opscode.com/install_server.html.

### Bootstrap the servers ###
There are two choices when bootstrapping servers. SoftLayer has provided an example script that can be edited for your needs, or you can manually bootstrap them on your own by following a chef-client install guide or installing chef-client on your own. It is recommended to use the sample bootstrap script.

Edit the script with each hardware server you would like to include in the OpenStack installation. It is highly recommended that at least three servers be used—one as the controller, one as a network server, and one as a compute server. After the bootstrap process completes, the script will assign one or more OpenStack recipes to the hardware servers.  A three-server bootstrap example script is shown below.

	#!/bin/bash
	knife bootstrap controller.example.com -x innovation --sudo -i /home/USER/.ssh/id_rsa -E MyOpenStack
	knife bootstrap network.example.com -x innovation --sudo -i /home/USER/.ssh/id_rsa -E MyOpenStack
	knife bootstrap compute.example.com -x innovation --sudo -i /home/USER/.ssh/id_rsa -E MyOpenStack
	
	knife node run_list add controller.example.com 'recipe[chef-openstack::mysql-glance]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::mysql-cinder]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::mysql-keystone]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::mysql-nova]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::mysql-neutron]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::rabbitmq-server]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::keystone]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::controller]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::cinder]'
	knife node run_list add controller.example.com 'recipe[chef-openstack::glance]'
	knife node run_list add network.example.com 'recipe[chef-openstack::neutron-network]'
	knife node run_list add compute.example.com 'recipe[chef-openstack::nova-kvm]'

### Run `chef-client` on the servers  ###
OpenStack makes use of several other open sources projects.  As such, it depends on them to be available before the deployment of core OpenStack services.  

Servers should be chef'ed in this order:

* All MySQL recipes
* RabbitMQ recipes
* Keystone recipes
* Controller recipes
* Any remaining recipes

		
		user@controller:~$ sudo chef-client
		Starting Chef Client, version 11.4.4
		resolving cookbooks for run list: ["chef-openstack::mysql-glance", "chef-openstack::mysql-cinder", "chef-
		openstack::mysql-keystone", "chef-openstack::mysql-nova", "chef-openstack::mysql-neutron", "chef-
		openstack::rabbitmq-server", "chef-openstack::keystone", "chef-openstack::controller", "chef-
		openstack::cinder", "chef-openstack::glance"]
		...
		...


### Verify Installation ###
Run the following commands on the controller to check if OpenStack has been deployed and is running correctly:

Run `source ~/.openrc` to update your environment so you can use the OpenStack command line tools. The .openrc file is located at /root/.openrc.

You may wish to add `source .openrc` to your `.bash_profile` file so that the CLI variables are set each time you log in:

    root@controller:~# echo "source ~/.openrc" >> ~/.bash_profile

    root@controller:~# source ~/.openrc

    root@controller:~# nova-manage service list
    Binary            Host                   Zone      Status   State  Updated_At
    nova-cert         controller.example.com  internal  enabled  :-)    2013-09-17 15:21:29
    nova-scheduler    controller.example.com  internal  enabled  :-)    2013-09-17 15:21:29
    nova-conductor    controller.example.com  internal  enabled  :-)    2013-09-17 15:21:29
    nova-consoleauth  controller.example.com  internal  enabled  :-)    2013-09-17 15:21:30
    nova-compute      compute.example.com     nova      enabled  :-)    2013-09-17 15:21:23

    root@controller:~# neutron agent-list
    +--------------------------------------+--------------------+-----------------------+-------+----------------+
    | id                                   | agent_type         | host                  | alive | admin_state_up |
    +--------------------------------------+--------------------+-----------------------+-------+----------------+
    | 438d2dd2-daf3-496c-99ad-179ed307b8d6 | Open vSwitch agent | compute.example.com   | :-)   | True           |
    | 4c684b66-16db-4853-8cb3-51098c3752b3 | L3 agent           | network.example.com   | :-)   | True           |
    | 98c3d818-0ebe-4cd6-89bf-0f107a7532ab | DHCP agent         | network.example.com   | :-)   | True           |
    | dd3b9134-ab76-440a-ba7a-70135202eb82 | Open vSwitch agent | network.example.com   | :-)   | True           |
    +--------------------------------------+--------------------+-----------------------+-------+----------------+

Services will have a `:-)` if they are working correctly and `XX` if they are not.

Authors
-------

Paul Sroufe ([psroufe@softlayer.com](mailto:psroufe@softlayer.com "Paul Sroufe"))  
Brian Cline ([bcline@softlayer.com](mailto:bcline@softlayer.com "Brian Cline"))  
