# Installation

The instructions below will guide you through the process of installing Chef, followed by the steps for bootstrapping and configuring
your nodes to achieve a functional private cloud installation.

> We strongly recommend that you review [OpenStack Requirements](#requirements) before starting. This is to
>   ensure that your environment is ready for install before getting in too deep.

## Install Chef

<div class="alert alert-info">You must install Chef Server first, and the Chef Server should be accessible by what will become your OpenStack nodes on ports
443 and 80.</div>

The Chef server acts as a hub for configuration data. It stores cookbooks, policies applied to each node, and metadata that describes
each registered Chef node being managed by the chef-client command. Nodes use the `chef-client` command to ask the server for
configuration details, such as recipes, templates, and file distributions. The `chef-client` command then performs much of the
configuration work on the nodes themselves without much interaction with the server. This scalable approach provides consistent
configuration management and quick deployments.

To install Chef Server, perform the following:

<ol>
  <li>Go to <a href="http://www.opscode.com/chef/install">http://www.opscode.com/chef/install</a>.
  </li>
  <li>Click the Chef Server tab.</li>
  <li>Select the operating system, version, and architecture that match the server from which you will run Chef Server.</li>
  <li>Select the version of Chef Server to download, and then click the link that appears to download the package.</li>
  <li>Install the downloaded package using the correct method for the operating system on which Chef Server will be installed. For
  instance, on Ubuntu and Debian, using <code>sudo dpkg -i package.deb</code> will perform the installation.</li>
  <li>Configure Chef Server by running the command below. This command will set up all required components, including Erchef, RabbitMQ,
  PostgreSQL, and the cookbooks that are needed by <code>chef-solo</code> to maintain Chef Server.</li>
<pre><code>$ sudo chef-server-ctl reconfigure</code></pre>

<img class="img-thumbnail" src="{{ page.baseurl }}images/installation/001.png">

  <li>Verify the hostname for the server by running the <code>hostname</code> command. The hostname for the server must be a fully
  qualified domain name (<span class="caps">FQDN</span>). We recommend as well that the proper <code>A</code> records for each of your
  nodes&#8217; <span class="caps">FQDN</span>s exist in <span class="caps">DNS</span> for easier accessibility.</li>
  <li>When you&#8217;re finished, verify the installation of Chef Server by running the following command:</li>
<pre><code>$ sudo chef-server-ctl test</code></pre>
</ol>

This will run the <code>chef-pedant</code> test suite against the installed Chef Server and will report that everything is installed
correctly and running smoothly.

## Install OpenStack

<ol>
  <li>Configure a bootstrap script with the hardware servers and/or cloud compute instances (<span class="caps">CCI</span>s) that you wish
  to bootstrap with Chef; this can be done in a simple shell script. Ensure you substitute the proper <span class="caps">FQDN</span>, the
  remote user name that has password-less <code>sudo</code> access, the local path to that user&#8217;s private <span class=
  "caps">SSH</span> key, and name of the Chef environment in which the node resides. In this example, we represent these with <span class="caps">FQDN</span>, <span class="caps">USER</span>, and <span class="caps">ENVIRONMENT</span>, respectively.</li>

<pre><code>knife bootstrap FQDN -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT</code></pre>

  <li>Edit the role information for each server and role.</li>

<pre><code>knife node run_list add FQDN &#39;role[openstack-controller]&#39;</code></pre>

  <li>Run the bootstrap script you&#8217;ve just created to prepare each server before running <code>chef-client</code>.</li>
  <li>Modify the required attributes through Chef environment overrides.</li>
  <li>Run the `chef-client` program on each server to start installation and configuration. Be sure to run the installs in this order:

    <ul>
      <li>MySQL roles</li>

      <li>RabbitMQ roles</li>

      <li>Keystone role</li>

      <li>Controller role</li>

      <li>All remaining roles</li>
    </ul>
  </li>
</ol>

## Prepare Chef

Before OpenStack can be installed to any servers, the private cloud repository needs to be downloaded locally and then uploaded to your
Chef Server. To do this, prepare a default Chef directory structure with this command:

<pre>
$ git clone git://github.com/opscode/chef-repo.git
</pre>

Change directory into `~/chef-repo/cookbooks` and then download the private cloud repository:

<pre>
$ cd chef-repo/cookbooks
$ git clone https://github.com/softlayer/chef-openstack
</pre>

The private cloud repository also depends on several Opscode cookbooks. Download them into the `~/chef-repo/cookbooks`
directory:

<pre>
$ git clone https://github.com/opscode-cookbooks/mysql
$ git clone https://github.com/opscode-cookbooks/partial_search
$ git clone https://github.com/opscode-cookbooks/ntp
$ git clone https://github.com/opscode-cookbooks/build-essential
$ git clone https://github.com/opscode-cookbooks/openssl
</pre>

The needed OpenStack roles are packaged within the private cloud repository. Copy the roles from the `chef-openstack/` directory to
the `~/chef-repo/roles` directory.

<pre>
$ cp -r ~/chef-repo/cookbooks/chef-openstack/roles ~/chef-repo/roles
</pre>

Finally, upload the cookbooks and roles to your Chef server for deployment to remote nodes:

<pre>
$ knife cookbook upload --all
$ knife role from file ~/chef-repo/roles/*
</pre>

If you get any errors during the upload, check that your `cookbook_path` and `role_path` are set correctly in the
`~/.chef/knife.rb`. You can optionally re-run the `knife` configuration client.

## Bootstrap Your Nodes

Bootstrapping is a Chef term for remotely deploying the chef client to a server. It creates the node and client objects in the Chef
Server and also adds client keys to both the server and client, allowing to chef-client communicate with the Chef Server.

Two choices are available for bootstrapping nodes. SoftLayer has provided example scripts, which can be edited for your needs, or you
can bootstrap them on your own by following a `chef-client` install guide or installing `chef-client` on your own. It
is recommended to use the bootstrap scripts.

Edit the script for each hardware node you would like to include in the OpenStack installation. It is highly recommended that at least
three nodes be used—-one for a controller node, one for a network node, and one for a compute node. After the bootstrap process completes,
the script will assign an OpenStack role to the hardware nodes. A node can have more than one role. A three-node bootstrap example script
is shown below.

<output><pre>#!/bin/bash

## Bootstrap three nodes with chef-client, registering them with Chef Server
knife bootstrap control1.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
knife bootstrap compute2.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT
knife bootstrap network3.example.com -x USER --sudo -i ~/.ssh/id_rsa -E ENVIRONMENT

## Now, add specific roles to each node&#39;s run list that will run once chef-client is run
## Controller node:
knife node run_list add control1.example.com &#39;role[openstack-mysql-all]&#39;
knife node run_list add control1.example.com &#39;role[openstack-rabbitmq]&#39;
knife node run_list add control1.example.com &#39;role[openstack-cinder]&#39;
knife node run_list add control1.example.com &#39;role[openstack-keystone]&#39;
knife node run_list add control1.example.com &#39;role[openstack-glance]&#39;
knife node run_list add control1.example.com &#39;role[openstack-controller]&#39;

## Compute node:
knife node run_list add compute2.example.com &#39;role[openstack-compute]&#39;

## Network node:
knife node run_list add network3.example.com &#39;role[openstack-network]&#39;</pre></output>

## Configure Chef

You will need to override some attributes for your OpenStack Chef deployment. These can be overridden at the environment level or at the
node level, but the environment level is **strongly** recommended.

First, create an environment. It will be used to house your nodes and configuration attributes. The attribute overrides will modify the
OpenStack for your deployment without the need to edit the recipes directly.

<pre>
$ knife environment create NAME -d &quot;Description for environment&quot;
</pre>

Edit your environment with the following command (you may also edit this from the Chef web-based UI). An editor will open where you may
define your environment&#8217;s attributes in <span class="caps">JSON</span> format.

<pre>
$ knife environment edit ENVIRONMENT
</pre>

Take special care to ensure your final environment document is valid <span class="caps">JSON</span>, as `knife` may discard
your attempted change if the <span class="caps">JSON</span> does not properly validate once you save and exit the editor.

The following is an example of the recommended minimum attributes that can be overridden in the environment, illustrating the required
attributes to deploy:

<output><pre>"override_attributes": {
    "admin": {
      "password": "admin_pass"
    },
    "network": {
      "public_interface": "eth1",
      "private_interface": "eth0"
    },
    "neutron": {
      "db": {
        "password": "my_new_neutron_pass"
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
}</pre></output>

## Chef Your Nodes

The process below outlines how to sequentially _chef_ the nodes. The order in which services come online is important. All
OpenStack components depend on MySQL and RabbitMQ, therefore those roles must be completed before attempting to deploy OpenStack-specific
components.

### MySQL and RabbitMQ Nodes

If you have chosen to make the MySQL node separate from the controller, you must first complete a deployment of the MySQL role
**prior** to chefing another node with any OpenStack services. You may easily deploy MySQL roles for each OpenStack component
by adding your additional nodes to the sample script above and specifying which MySQL role(s) to apply to each. This is discussed in the
Scaling &amp; Branching Deployments section.

Similarly, if you intend to deploy RabbitMQ on a separate server, you may follow the same process, but deploying the RabbitMQ role must
be performed prior to chefing the controller with any OpenStack services. It is independent of the MySQL roles.

Otherwise, please skip to the next step if MySQL and RabbitMQ will run from your controller node.

### Controller Node

The controller node contains, at a minimum, the roles for the base Neutron and Nova services. If you are unfamiliar with OpenStack, it is recommended to do a standard installation as illustrated in the bootstrap example. Be sure that Chef shows that the node contains the MySQL backend, RabbitMQ, Keystone, Cinder, and Glance roles. You can verify this with a simple `knife` command:

<pre>
knife node show FQDN
</pre>

The output should look similar to this:

<output><pre class="nowrap"><div style="width:828px; overflow-x: scroll; overflow-y: hidden;">Node Name: control1.example.com
Environment: Region
FQDN: control1.example.com
IP: XX.XX.XX.XX
Run List: role[openstack-mysql-cinder], role[openstack-mysql-glance], role[openstack-mysql-keystone], role[openstack-mysql-nova], role[openstack-mysql-neutron], role[openstack-rabbitmq], role[openstack-keystone], role[openstack-controller], role[openstack-cinder], role[openstack-glance]
Roles: openstack-mysql-cinder, openstack-mysql-glance, openstack-mysql-keystone, openstack-mysql-nova, openstack-mysql-neutron, openstack-rabbitmq, openstack-keystone, openstack-controller, openstack-cinder, openstack-glance
Recipes: chef-openstack::set_attributes, chef-openstack::set_cloudnetwork, ntp, chef-openstack::mysql-cinder, chef-openstack::mysql-glance, chef-openstack::mysql-keystone, chef-openstack::mysql-nova, chef-openstack::mysql-neutron, chef-openstack::ip_forwarding, chef-openstack::repositories, chef-openstack::rabbitmq-server, chef-openstack::keystone, chef-openstack::neutron-controller, chef-openstack::nova, chef-openstack::dashboard, chef-openstack::cinder, chef-openstack::glance, chef-openstack::neutron-network
Platform: ubuntu 12.04
Tags:
</div></pre></output>

To chef the controller node you can either connect directly to the remote server and (with root privileges) run `chef-client`
from the node itself or use [knife ssh](http://docs.opscode.com/knife_ssh.html) to run it from the Chef server:

<pre>
knife ssh SEARCH_TERM &#39;sudo chef-client&#39;
</pre>

For example:

<pre>
knife ssh &#39;role:openstack-controller&#39; &#39;sudo chef-client&#39;
</pre>

&#8230;or

<pre>
knife ssh &#39;name:FQDN&#39; &#39;sudo chef-client&#39;
</pre>

### Other Network and Compute Nodes

After the MySQL, RabbitMQ, and controller roles have been chefed, any of the remaining roles can then be run in any order for the other
nodes, and can even be run in parallel to speed up your total deployment time. Compute and Network nodes can also be added any time after
the initial deployment. Following the example above, the two commands would chef your network and compute nodes:

<pre>
## Compute node:
knife ssh &#39;name:FQDN_2&#39; &#39;sudo chef-client&#39;
## Network node:
knife ssh &#39;name:FQDN_3&#39; &#39;sudo chef-client&#39;
</pre>