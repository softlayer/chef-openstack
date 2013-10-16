# Installing OpenStack

The instructions below will guide you through the process of installing Chef,
followed by the steps for bootstrapping and configuring your nodes to achieve
a functional private cloud installation.


> We strongly recommend that you review [OpenStack Requirements](openstack-requirements.md) before starting. This
is to ensure that your environment is ready for install before getting in too
deep.

## Install Chef

**You must install Chef Server first, and the Chef Server should be accessible by what will become your OpenStack nodes on ports 443 and 80.**

The Chef server acts as a hub for configuration data. It
stores cookbooks, policies applied to each node, and metadata that describes
each registered Chef node being managed by the chef-client command. Nodes use
the `chef-client` command to ask the server for
configuration details, such as recipes, templates, and file distributions. The
`chef-client` command then performs much of the
configuration work on the nodes themselves without much interaction with the
server. This scalable approach provides consistent configuration management
and quick deployments.

To install Chef Server, perform the following:

1. Go to [http://www.opscode.com/chef/install](http://www.opscode.com/chef/install).
2. Click the Chef Server tab.
3. Select the operating system, version, and architecture that match the server from which you will run Chef Server.
4. Select the version of Chef Server to download, and then click the link that appears to download the package.
5. Install the downloaded package using the correct method for the operating system on which Chef Server will be installed. For instance, on Ubuntu and Debian, using `sudo dpkg -i package.deb` will perform the installation.
6. Configure Chef Server by running the following command:

        $ sudo chef-server-ctl reconfigure

This command will set up all required components, including Erchef, RabbitMQ,
PostgreSQL, and the cookbooks that are needed by `chef-solo` to maintain Chef Server.

> Add gliffy image here

7. Verify the hostname for the server by running the `hostname` command. The hostname for the server must be a fully qualified domain name (FQDN). We recommend as well that the proper `A` records for each of your nodes' FQDNs exist in DNS for easier accessibility.
8. Verify the installation of Chef Server by running the following command:

        $ sudo chef-server-ctl test

This will run the `chef-pedant` test suite against the
installed Chef Server and will report that everything is installed correctly
and running smoothly.

## Install OpenStack

The instructions below provide a general overview of steps you will perform to
install an OpenStack environment with private cloud. It demonstrates a typical
OpenStack installation, and includes additional information about customizing
or modifying your installation. Generally, your installation will follow these
steps, with more details outlined in the other sections below.

1.  Configure a bootstrap script with the hardware servers
and/or cloud compute instances (CCIs) that you wish to bootstrap with Chef;
this can be done in a simple shell script. Ensure you substitute the proper
FQDN, the remote user name that has password-less `sudo`
access, the local path to that user's private SSH key, and name of the Chef
environment in which the node resides. In this example, we represent these
with FQDN, USER, and ENVIRONMENT, respectively.

        knife bootstrap FQDN -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT

    
2.  Edit the role information for each server and role.

        knife node run_list add FQDN 'role[grizzly-controller]'

3.  Run the bootstrap script you've just created to prepare each server before running `chef-client`.
4.  Modify the required attributes through Chef environment overrides.
5.  Run the `chef-client` program on each server to start installation and configuration. Be sure to run the installs in this order:

    * MySQL roles
    * RabbitMQ roles
    * Keystone role
    * Controller role
    * All remaining roles

## Prepare Chef for OpenStack Deployment

Before OpenStack can be installed to any servers, the private cloud repository
needs to be downloaded locally and then uploaded to your Chef Server. To do
this, prepare a default Chef directory structure with this command:

	$ git clone git://github.com/opscode/chef-repo.git

Change directory into `~/chef-repo/cookbooks` and then download the private cloud repository:

    $ cd chef-repo/cookbooks
    $ git clone https://github.com/softlayer/TODO:PUBLIC_REPO_NAME

The private cloud repository also depends on several Opscode cookbooks. Download them into the `~/chef-repo/cookbooks` directory:

    $ git clone https://github.com/opscode-cookbooks/mysql
    $ git clone https://github.com/opscode-cookbooks/partial_search
    $ git clone https://github.com/opscode-cookbooks/ntp
    $ git clone https://github.com/opscode-cookbooks/build-essential
    $ git clone https://github.com/opscode-cookbooks/openssl

The needed OpenStack roles are packaged within the private cloud repository.
Copy the roles from the `grizzly/` directory to the `~/chef-repo/roles` directory.

	$ cp -r ~/chef-repo/cookbooks/TODO:PUBLIC_REPO_NAME/roles ~/chef-repo/roles

Finally, upload the cookbooks and roles to your Chef server for deployment to
remote nodes:

	$ knife cookbook upload --all
	$ knife role from file ~/chef-repo/roles/*

If you get any errors during the upload, check that your `cookbook_path` and
`role_path` are set correctly in the `~/.chef/knife.rb`. You can optionally re-run the `knife` configuration client.

## Bootstrap Your Nodes

Bootstrapping is a Chef term for remotely deploying the chef client to a
server.   It creates the node and client objects in the Chef
Server and also adds client keys to both the server and client, allowing to
chef-client communicate with the Chef Server.

Two choices are available for bootstrapping nodes. SoftLayer has provided
example scripts, which can be edited for your needs, or you can bootstrap them
on your own by following a `chef-client` install guide or
installing `chef-client` on your own. It is recommended to
use the bootstrap scripts.

Edit the script for each hardware node you would like to include in the
OpenStack installation. It is highly recommended that at least three nodes be
used—one for a controller node, one for a network node, and one for a compute
node. After the bootstrap process completes, the script will assign an
OpenStack role to the hardware nodes. A node can have more than one role. A
three-node bootstrap example script is shown below.

	#!/bin/bash
		 
	## Bootstrap three nodes with chef-client, registering them with Chef Server
	knife bootstrap control1.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
	knife bootstrap compute2.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
	knife bootstrap network3.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
		 
	## Now, add specific roles to each node's run list that will run once `chef-client` is run
	## Controller node:
	knife node run_list add control1.example.com 'role[grizzly-mysql-all]'
	knife node run_list add control1.example.com 'role[grizzly-rabbitmq]'
	knife node run_list add control1.example.com 'role[grizzly-cinder]'
	knife node run_list add control1.example.com 'role[grizzly-keystone]'
	knife node run_list add control1.example.com 'role[grizzly-glance]'
	knife node run_list add control1.example.com 'role[grizzly-controller]'
		 
	## Compute node:
	knife node run_list add compute2.example.com 'role[grizzly-compute]'
		 
	## Network node:
	knife node run_list add network3.example.com 'role[grizzly-network]'

## Configure Chef Overrides for OpenStack

You will need to override some attributes for your OpenStack Chef deployment.
These can be overridden at the environment level or at the node level, but the
environment level is **strongly** recommended.

First, create an environment. It will be used to house your nodes and
configuration attributes. The attribute overrides will modify the OpenStack
for your deployment without the need to edit the recipes directly.

	$ knife environment create NAME -d "Description for environment"

Edit your environment with the following command (you may also edit this from
the Chef web-based UI). An editor will open where you may define your
environment's attributes in JSON format.

	$ knife environment edit ENVIRONMENT

Take special care to ensure your final environment document is valid JSON, as
`knife` may discard your attempted change if the JSON does
not properly validate once you save and exit the editor.

The following is an example of the recommended minimum attributes that can be
overridden in the environment, illustrating the required attributes to deploy:

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

## Chef Your Nodes

The process below outlines how to sequentially _chef_ the nodes. The order in
which services come online is important. All OpenStack components depend on
MySQL and RabbitMQ, therefore those roles must be completed before attempting
to deploy OpenStack-specific components.

### MySQL and RabbitMQ Nodes

If you have chosen to make the MySQL node separate from the controller, you
must first complete a deployment of the MySQL role **prior**
to chefing another node with any OpenStack services. You may easily deploy
MySQL roles for each OpenStack component by adding your additional nodes to
the sample script above and specifying which MySQL role(s) to apply to each.
This is discussed in the Scaling & Branching Deployments section.

Similarly, if you intend to deploy RabbitMQ on a separate server, you may
follow the same process, but deploying the RabbitMQ role must be performed
prior to chefing the controller with any OpenStack services. It is independent
of the MySQL roles.

Otherwise, please skip to the next step if MySQL and RabbitMQ will run from
your controller node.

### Controller Node

The controller node contains, at a minimum, the roles for the base Quantum and
Nova services. If you are unfamiliar with OpenStack, it is recommended to do a
standard installation as illustrated in the bootstrap example. Be sure that
Chef shows that the node contains the MySQL backend, RabbitMQ, Keystone,
Cinder, and Glance roles. You can verify this with a
simple `knife` command:

	knife node show FQDN

The output should look similar to this:

	Node Name:   control1.example.com
	Environment: Region
	FQDN:        control1.example.com
	IP:          XX.XX.XX.XX
	Run List:    role[grizzly-mysql-cinder], role[grizzly-mysql-glance], role[grizzly-mysql-keystone], role[grizzly-mysql-nova], role[grizzly-mysql-quantum], role[grizzly-rabbitmq], role[grizzly-keystone], role[grizzly-controller], role[grizzly-cinder], role[grizzly-glance]
	Roles:       grizzly-mysql-cinder, grizzly-mysql-glance, grizzly-mysql-keystone, grizzly-mysql-nova, grizzly-mysql-quantum, grizzly-rabbitmq, grizzly-keystone, grizzly-controller, grizzly-cinder, grizzly-glance
	Recipes:     grizzly::set_attributes, grizzly::set_cloudnetwork, ntp, grizzly::mysql-cinder, grizzly::mysql-glance, grizzly::mysql-keystone, grizzly::mysql-nova, grizzly::mysql-quantum, grizzly::ip_forwarding, grizzly::repositories, grizzly::rabbitmq-server, grizzly::keystone, grizzly::quantum-controller, grizzly::nova, grizzly::dashboard, grizzly::cinder, grizzly::glance, grizzly::quantum-network
	Platform:    ubuntu 12.04
	Tags:
    
    

To chef the controller node you can either connect directly to the remote
server and (with root privileges) run `chef-client` from the node itself or
use [knife ssh](http://docs.opscode.com/knife_ssh.html) to run it from the
Chef server:

	knife ssh SEARCH_TERM 'sudo chef-client'

For example:

	knife ssh 'role:grizzly-controller' 'sudo chef-client'

or

	knife ssh 'name:FQDN' 'sudo chef-client'

### Other Network and Compute Nodes

After the MySQL, RabbitMQ, and controller roles have been chefed, any of the
remaining roles can then be run in any order for the other nodes, and can even
be run in parallel to speed up your total deployment time. Compute and Network
nodes can also be added any time after the initial deployment. Following the
example above, the two commands would chef your network and compute nodes:

	## Compute node:
	knife ssh 'name:FQDN_2' 'sudo chef-client'
	 
	## Network node:
	knife ssh 'name:FQDN_3' 'sudo chef-client'
