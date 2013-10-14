Vagrant
=======

Vagrant provides a quick and configuration-free platform to test drive the SoftLayer private cloud recipes on your own. Vagrant uses VirtualBox to preconfigure virtual machines without manual intervention.  Vagrant will be used to deploy Chef Server, download and install the SoftLayer private cloud cookbook, and then provision the OpenStack all-in-one node. This workflow is similar to what is seen in a production environment, and will work for Microsoft Windows and most Linux distributions.

Create an All-in-One Sandbox
----------------------------

The SoftLayer Vagrant deployment requires 3 files:

1. **Vagrantfile** - The core configuration file for Vagrant.  It instructs Vagrant how to create VirtualBox machines and what to run after they are created.
2. **install-chef-server.sh** - This file is run after the chef-server VirtualBox machine is running.  It downloads, installs, and configures a fully working chef environment.
3. **prepare-openstack.sh** - Sets up the VirtualBox machine to be ready for a Chef deployment of OpenStack.

Install Vagrant
---------------
