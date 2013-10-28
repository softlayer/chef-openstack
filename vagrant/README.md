Vagrant
=======

Vagrant provides a quick and configuration-free platform to test drive the SoftLayer Chef recipes on your own. Vagrant uses VirtualBox to preconfigure virtual machines without manual intervention. Vagrant will be used to deploy Chef Server, download and install the SoftLayer Chef cookbooks, and then provision an OpenStack all-in-one node. This workflow is similar to what is seen in a production environment, and will work for Microsoft Windows and most Linux distributions.

After Vagrant has finished, you will have a Chef Server and OpenStack all-in-one node to explore.   You will be able to see the Chef recipes, OpenStack node, and environment and familiarize yourself with them before deploying to a real environment.  The full OpenStack Horizon interface will also be available.   Use `vagrant ssh openstack` to access the OpenStack CLI.

> OpenStack is meant to be run on hardware with virtual extensions enabled.  Running VM's inside Vagrant will be slow.

Create an All-in-One Sandbox
============================

Install Vagrant
---------------
Download the latest version from [http://downloads.vagrantup.com/](http://downloads.vagrantup.com/ "http://downloads.vagrantup.com/").  Install it per your operating systems instructions.

Install VirtualBox
------------------
Download the latest version from [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads "https://www.virtualbox.org/wiki/Downloads").  Install it per your operating systems instructions.

Launch Vagrant Up
-----------------
Download the Vagrant file from the SoftLayer chef repo at [https://github.com/softlayer/chef-openstack](https://github.com/softlayer/chef-openstack).

Then, open a command prompt or terminal and run:

    vagrant up

Vagrant will provision a fully working Chef server and OpenStack all-in-one node  on two separate VirtualBox machines.  You can be explore each from your computer's browser.

Chef-Server is located at: https://127.0.0.1/  login: admin password: p@ssw0rd1

Openstack is located at: http://127.0.0.1:7081 login: admin password: passwordsf


