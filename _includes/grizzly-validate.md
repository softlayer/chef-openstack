# Using OpenStack

Here’s how to start getting familiar with the OpenStack client utilities.

## Using Your Private Cloud

You can access the OpenStack command-line tools by logging in to the Controller node via <span class="caps">SSH</span> as root, and
running the following commands:

<pre>
# source .openrc
</pre>
<pre>
# nova flavor-list
</pre>

The output should look similar to this:

<output><pre>
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
| ID |    Name   | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
| 1  | m1.tiny   | 512       | 0    | 0         |      | 1     | 1.0         | True      |
| 2  | m1.small  | 2048      | 10   | 20        |      | 1     | 1.0         | True      |
| 3  | m1.medium | 4096      | 10   | 40        |      | 2     | 1.0         | True      |
| 4  | m1.large  | 8192      | 10   | 80        |      | 4     | 1.0         | True      |
| 5  | m1.xlarge | 16384     | 10   | 160       |      | 8     | 1.0         | True      |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
</pre></output>

This is a list of "flavors" — different disk, memory, and <span class="caps">CPU</span> allocations that you can assign to instances. This is an example of the information that you can access through the python-novaclient command line client.

The list of available images to boot from is seen by this command.

<pre>
# nova image-list
</pre>

The output should look similar to this:

<output><pre>
+--------------------------------------+-----------------------------------+--------+--------+
| ID                                   | Name                              | Status | Server |
+--------------------------------------+-----------------------------------+--------+--------+
| 3470a8b5-46a7-442b-ac75-7c8f663e271d | CirrOS 0.3.0 i386                 | ACTIVE |        |
| ace57487-30b6-41c9-9e7a-9d44f103437d | CirrOS 0.3.0 x86_64               | ACTIVE |        |
| 3722fed6-0065-4521-b480-8abd5f7abf2c | Fedora 18 (Cloud) i386            | ACTIVE |        |
| 21c3f3ae-f773-46f9-8fef-d3c0a712ef45 | Fedora 18 (Cloud) x86_64          | ACTIVE |        |
| dbda560c-8e09-4035-9332-03ef4470a934 | Fedora 19 (Cloud) i386            | ACTIVE |        |
| c2ac12e3-5f11-4679-8074-232c5040b901 | Fedora 19 (Cloud) x86_64          | ACTIVE |        |
| 2baacb65-fa9d-4707-9856-5b6d5803d63e | Ubuntu 12.04 Server (Cloud) amd64 | ACTIVE |        |
| 49a33caa-8e78-41c3-8af6-cc5ea25182f2 | Ubuntu 12.04 Server (Cloud) i386  | ACTIVE |        |
| 5b8998ce-40fa-43cb-9f79-11f4e9a32296 | Ubuntu 12.10 Server (Cloud) amd64 | ACTIVE |        |
| e8f69a8b-c1f5-4432-89bb-6bfecfea7cc3 | Ubuntu 12.10 Server (Cloud) i386  | ACTIVE |        |
| 668e92c6-b6c0-4f9e-bf0d-078ede9667e9 | Ubuntu 13.04 Server (Cloud) amd64 | ACTIVE |        |
| 169fc708-cdbf-4dd3-a106-ced48a88922f | Ubuntu 13.04 Server (Cloud) i386  | ACTIVE |        |
+--------------------------------------+-----------------------------------+--------+--------+
</pre></output>

To launch an instance, find the image ID and flavor name you would like to use.

<pre>
# nova boot --flavor=2 --image=2baacb65-fa9d-4707-9856-5b6d5803d63e ubuntu
</pre>

The output should look similar to this:

<output><pre>
+-------------------------------------+--------------------------------------+
| Property                            | Value                                |
+-------------------------------------+--------------------------------------+
| status                              | BUILD                                |
| updated                             | 2013-10-02T21:18:01Z                 |
| OS-EXT-STS:task_state               | None                                 |
| OS-EXT-SRV-ATTR:host                | None                                 |
| key_name                            | None                                 |
| image                               | Ubuntu 12.04 Server (Cloud) amd64    |
| hostId                              |                                      |
| OS-EXT-STS:vm_state                 | building                             |
| OS-EXT-SRV-ATTR:instance_name       | instance-00000001                    |
| OS-EXT-SRV-ATTR:hypervisor_hostname | None                                 |
| flavor                              | m1.small                             |
| id                                  | e12449f2-0dfb-4aee-b7cf-8c97850c2b30 |
| security_groups                     | [{u'name': u'default'}]              |
| user_id                             | 36fcdb3ca5d349ffb82731b91c522080     |
| name                                | ubuntu                               |
| adminPass                           | RKTRUH52zfGL                         |
| tenant_id                           | a06ad73e633b4a479986f8de4b613e51     |
| created                             | 2013-10-02T21:18:01Z                 |
| OS-DCF:diskConfig                   | MANUAL                               |
| metadata                            | {}                                   |
| accessIPv4                          |                                      |
| accessIPv6                          |                                      |
| progress                            | 0                                    |
| OS-EXT-STS:power_state              | 0                                    |
| OS-EXT-AZ:availability_zone         | nova                                 |
| config_drive                        |                                      |
+-------------------------------------+--------------------------------------+
</pre></output>

You can also view the status of the controller and compute nodes and the Nova components active on each while logged in as the root
user.

<pre>
# nova-manage service list
</pre>

The output should look similar to this:

<output><pre>
Binary Host Zone Status State Updated_At
nova-conductor control1 nova enabled :-) 2013-09-20 10:41:39
nova-cert control1 nova enabled :-) 2013-09-20 10:41:36
nova-scheduler control1 nova enabled :-) 2013-09-20 10:41:34
nova-consoleauth control1 nova enabled :-) 2013-09-20 10:41:41
nova-compute compute2 nova enabled :-) 2013-09-20 10:41:35
</pre></output>

You can also view logs with the tail command. For example, to view nova-compute.log on your compute node(s), execute the following
command:

<pre>
# tail /var/log/nova/nova-compute.log
</pre>

All logs are available in the /var/log/ directory and its subdirectories. You may also view the status of Quantum agents that reside on
your network and compute nodes.

<pre>
# quantum agent-list
</pre>

The output should look similar to this:

<output><pre>
+--------------------------------------+--------------------+----------+-------+----------------+
| id                                   | agent_type         | host     | alive | admin_state_up |
+--------------------------------------+--------------------+----------+-------+----------------+
| 42b5f9cb-7244-499d-826a-2a056d987c44 | Open vSwitch agent | compute2 | :-)   | True           |
| c9846df5-5e13-4f7c-971e-c65dd660a2cb | Open vSwitch agent | network3 | :-)   | True           |
| 8eb94efa-8f41-44c8-8dc0-1387959de7be | DHCP agent         | network3 | :-)   | True           |
| d6fdc505-094b-4bcd-9cca-32410aa5e6e3 | L3 agent           | network3 | :-)   | True           |
+--------------------------------------+--------------------+----------+-------+----------------+
</pre></output>

### Accessing the Horizon Dashboard

> Note: Log in with the admin user name and the password you created during the OpenStack Chef deployment.

In addition to the command line, you can use your web browser to access the controller host. You can use the hostname or the IP address that you provided during installation, followed by &#8220;/horizon&#8221;. For instance, if your controller is &#8220;control1.example.com”, navigate to http://control1.example.com/horizon/. You should see the OpenStack dashboard login page. If not, the installation may not be complete.

After logging in, you can configure additional users, create, and manage OS images and other volumes, create or customize flavors, and launch instances. You also have the ability to view and create networks, routers, and subnets for use in your OpenStack environment.

### OpenStack Client Utilities

The OpenStack client utilities are a convenient way to interact with OpenStack using the command line from your own workstation without logging in to the controller node. The client utilities for Python are available via PyPi and can be installed on most Linux systems with these commands:

<pre>
pip install python-keystoneclient
pip install python-novaclient
pip install python-quantumclient
pip install python-cinderclient
pip install python-glanceclient
</pre>

> Note: Individual utilities are maintained by differing communities. Refer to their help documentation for more information, or by using the &#8212;help flag for a given utility.

## Our DevOps Tools

We offer two new tools to help interact with the SoftLayer environment:

1.  sl, a command line tool to view and manage SoftLayer resources (using our Python client library)
2.  swftp-chef, a Chef cookbook for swftp, our <span class="caps">SFTP</span>/SCP-based interface to Swift Object Storage

### SoftLayer Command Line Tool

When working with lots of servers, whether virtual or hardware, being able to automate tasks can be a blessing. While on a <span class="caps">CLI</span>, quickly sorting and grepping is commonplace for those in DevOps roles, but if you have found yourself writing something like this, these tools are probably for you:

<pre>
$ cat /proc/cpuinfo | grep &quot;model name&quot; | awk &#39;{ print $NF }&#39;
</pre>

We have extended the SoftLayer Python bindings to also ship with a new command line tool: sl. Simply install from PyPI, configure them with your user name and <span class="caps">API</span> key, and you are ready to go.

<pre>
## This command requires the python-setuptools package to be installed:
$ sudo easy_install softlayer

## This alternative method requires the python-pip package to be installed:
$ sudo pip install softlayer

## Then, set up your config, which will require your user name and <span class="caps">API</span> key:
$ sl config setup
</pre>

Voila! You are all setup and ready to rock. Give it a test run by trying out some of these commands:

<pre>
$ sl --help
$ sl cci list
$ sl hardware list
$ sl dns list
$ sl dns list | grep 20.. # notice how we adjusted the output for you? Great for sed/awk use.
$ sl dns list --format=table &gt; dns_zones.txt # redirects pretty tables output to a file.
</pre>

Development for this tool is out in the open on GitHub at [https://github.com/softlayer/softlayer-api-python-client](https://github.com/softlayer/softlayer-api-python-client). Documentation for it is also available on GitHub at [https://softlayer-api-python-client.readthedocs.org/en/latest](https://softlayer-api-python-client.readthedocs.org/en/latest). Do note that this is not full <span class="caps">API</span> documentation as seen on the SoftLayer Developer Network (<span class="caps">SLDN</span>) site, however it is a great resource for SoftLayer Python <span class="caps">API</span> references and examples.

### The swftp-chef Cookbook

To support our DevOps comrades even further, we have released swftp-chef. This simplifies the deployment of swftp—an <span class="caps">SFTP</span>-based interface to Swift—in your fleet even more. Installing is as simple as running one of these two commands:

<pre>
## If you have the knife-github gem installed, obtain it with this command:
$ knife cookbook github install softlayer/chef-swftp

## Otherwise, obtain it with this command:
$ knife cookbook site install swftp
</pre>

Afterwards, set the attributes on either the role/environment and add it to your run list. You can find a full list of swftp attributes in its README file.

## Scaling and Branching Deployments

The private cloud recipes were designed with scaling in mind. OpenStack was built to be scaled, but most small deployments adhere to the three-node model of a Compute, Network, and Controller node. SoftLayer provides several options for deployers who need to scale out. You can add Compute and Network nodes where necessary to compensate for load, and you can branch components of the install to separate servers in any configuration you choose. Going to be a heavy user of block storage? Move the Cinder role to a separate server and deploy it as the sole component on that system.

The private cloud is made up of 12 components:

*   OpenStack MySQL Servers
*   Quantum/Neutron
*   Nova
*   Cinder
*   Glance
*   Keystone
*   RabbitMQ
*   OpenStack Controller
*   OpenStack Nova Compute
*   OpenStack Quantum/Neutron
*   OpenStack Keystone Authentication
*   OpenStack Glance
*   OpenStack Cinder

The components (roles) can be branched into the traditional three-node OpenStack model.

<div class="table-responsive" id="component-table">
  <table class="table table-hover" id="no-borders">
    <thead>
      <tr>
        <th>Server</th>

        <th>Role(s)</th>
      </tr>
    </thead>

    <tbody>
      <tr>
        <td>OpenStack Controller</td>

        <td>MySQL</td>
      </tr>

      <tr>
        <td></td>

        <td>RabbitMQ</td>
      </tr>

      <tr>
        <td></td>

        <td>Keystone</td>
      </tr>

      <tr>
        <td></td>

        <td>Controller</td>
      </tr>

      <tr>
        <td></td>

        <td>Glance</td>
      </tr>

      <tr>
        <td></td>

        <td>Cinder</td>
      </tr>

      <tr>
        <td>OpenStack Compute</td>

        <td>Nova</td>
      </tr>

      <tr>
        <td>OpenStack Network</td>

        <td>Quantum/Neutron</td>
      </tr>
    </tbody>
  </table>
</div>

At scale, you may wish to have some separation of these roles to handle the increased load on any single component. Database roles can actually be split and scaled out to suit environments with heavy database churn or a desire for stronger isolation, helping to more evenly distribute load:

<div class="table-responsive" id="component-table">
  <table class="table table-hover" id="no-borders">
    <thead>
      <tr>
        <th>Server</th>

        <th>Role(s)</th>
      </tr>
    </thead>

    <tbody>
      <tr>
        <td>OpenStack Controller</td>

        <td>MySQL</td>
      </tr>

      <tr>
        <td></td>

        <td>Quantum/Neutron</td>
      </tr>

      <tr>
        <td></td>

        <td>Nova</td>
      </tr>

      <tr>
        <td></td>

        <td>RabbitMQ</td>
      </tr>

      <tr>
        <td></td>

        <td>Controller</td>
      </tr>

      <tr>
        <td>OpenStack Authentication</td>

        <td>Keystone</td>
      </tr>

      <tr>
        <td></td>

        <td>MySQL</td>
      </tr>

      <tr>
        <td></td>

        <td>Keystone</td>
      </tr>

      <tr>
        <td>OpenStack Block Storage</td>

        <td>Cinder</td>
      </tr>

      <tr>
        <td></td>

        <td>MySQL</td>
      </tr>

      <tr>
        <td></td>

        <td>Cinder</td>
      </tr>

      <tr>
        <td>OpenStack Image Store</td>

        <td>Glance</td>
      </tr>

      <tr>
        <td></td>

        <td>MySQL</td>
      </tr>

      <tr>
        <td></td>

        <td>Glance</td>
      </tr>

      <tr>
        <td>OpenStack Compute</td>

        <td>Nova</td>
      </tr>

      <tr>
        <td>OpenStack Network</td>

        <td>Quantum/Neutron</td>
      </tr>
    </tbody>
  </table>
</div>

In such a scenario, high load on a single component is far less likely to adversely affect the performance of another component. This flexibility allows you to use the hardware you already have more effectively—before having to spend money on beefier hardware.