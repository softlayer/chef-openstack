# All-in-One Sandbox

This section is designed to illustrate a proof-of-concept installation for learning or development purposes, in which you may wish to run everything on a single machine. This installation process includes:

## Create Your Own Sandbox

1.  Installing VirtualBox on your laptop or desktop
2.  Installing Vagrant on your laptop or desktop
3.  Creating one VirtualBox VM for Chef Server
4.  Creating a second VirtualBox VM for OpenStack
5.  Deploying OpenStack in your second VM using the Chef Server in your first VM

## Introduction to Vagrant

Vagrant provides a quick and configuration-free platform to test drive the SoftLayer private cloud recipes on your own. Vagrant uses VirtualBox to preconfigure virtual machines without manual intervention. In this section, Vagrant will be used to deploy Chef Server, install the SoftLayer private cloud cookbook, and then provision the OpenStack all-in-one node. This workflow is similar to what is seen in a production environment, and will work for Microsoft Windows and most Linux distributions.

## Installation Process

Follow the instructions below to install Virtual Box and Vagrant.

### Install VirtualBox

<ol>
	<li>Go to the <a href="https://www.virtualbox.org/wiki/Downloads">Virtual Box download page</a></li>
			<img class="img-thumbnail" height="550px" src="{{ page.baseurl }}img/sandbox/006.png">
	<li>Download the AMD64 version for your operating system.</li>
	<li>Install VirtualBox using the downloaded package. For example, on Ubuntu and Debian Linux, run the following command:</li>
			<pre><code>$ dpkg -i virtualbox-4.2_4.2.18-88780~Ubuntu~precise_amd64.deb</code></pre>
	<li>On Windows, proceed through installation using the setup wizard:</li>
			<img class="img-thumbnail" src="{{ page.baseurl }}img/sandbox/002.png">
</ol>

### Install Vagrant

<ol>
	<li>Go to the <a href="http://downloads.vagrantup.com">Vagrant download page</a>.</li>
	<li>Click the latest version. (At the time this guide was written, the most recent version was 1.3.3.)</li>
			<img class="img-thumbnail" src="{{ page.baseurl }}img/sandbox/003.png">
	<li>Download the package for your operating system.</li>
	<li>Install Vagrant from the package.</li>
			<img class="img-thumbnail" src="{{ page.baseurl }}img/sandbox/004.png">
</ol>

#### Download the Vagrant File Scripts

<ol>
	<li>Make a temporary directory to place the Vagrant files.</li>
<pre><code>## Linux command:
$ mkdir ~/softlayer
## Windows command:
> mkdir C:\softlayer</code></pre>
	<li>Next, save the Vagrant files to the created location and open a terminal window or Windows command line window.</li>
	<li>Change your directory (cd) to the vagrant directory you just created.</li>
	<li>Run vagrant up.</li>
	<li>The install will take approximately 15 minutes, and will provision two VirtualBox VMs, install Chef Server, and bootstrap the OpenStack installation.</li>
	<li>After completion, the Vagrant script will tell you how to access the new Chef Server, as well as Horizon (the OpenStack dashboard).</li>
			<img class="img-thumbnail" src="{{ page.baseurl }}img/sandbox/007.png">
</ol>

### Navigation

Vagrant uses VirtualBox to deploy Chef Server and OpenStack. Running OpenStack compute instances inside an already virtualized environment is very slow compared to the speed of a hardware deployment.

### Chef Server

1.  From your computer’s browser, navigate to [https://127.0.0.1/](https://127.0.0.1/).
2.  The Chef server uses a self-generated, unsigned certificate. There will be a prompt to accept and proceed.
3.  The Chef Server login prompt will be next. Enter in the following credentials:
	* username: admin
	* password: p@ssw0rd1

<img class="img-thumbnail" src="{{ page.baseurl }}img/sandbox/009.png">

### OpenStack

1.  From your computer’s browser, navigate to [http://127.0.0.1:7081/horizon/](http://127.0.0.1:7081/horizon/).
2.  Log into OpenStack using the provided credentials:
	* username: admin
	* password: passwordsf

<img class="img-thumbnail" src="{{ page.baseurl }}img/sandbox/010.png">