# OpenStack Requirements

Review the requirements below in their entirety before beginning installation.

## Node Requirements

Consistent with OpenStack's reference architecture, we recommend a minimum of the following three nodes to operate an officially supported architecture. These are optimal for users seeking a private cloud offering on the SoftLayer platform.

  * Cloud Controller Node
  * Network Node
  * Compute Node

> Note: OpenStack can scale to hundreds or thousands of nodes. Running
OpenStack on systems that do not meet the minimum requirements may negatively
affect system or overall cluster performance.

|Hardware|Cloud Controller Node|Network Node|Compute Node|
| --- | --- | --- | --- |
|System|Dual Processor|Single Processor|Dual Processor|
|RAM|16 GB or greater|8 GB or greater|16 GB or greater|
|Processor|Quad-Core Xeon or greater|Quad-Core Xeon or greater|Quad-Core Xeon or greater
|Disk (OS Drive)|Two physical disks in RAID1|Two physical disks in RAID1|Two physical disks in RAID1
|Disk (MySQL Database)|Two physical disks in RAID0 or RAID1,or 4+ physical disks in RAID10|N/A|N/A|
|Disk (Cinder Volumes)|Two physical disks1 in RAID1,or 4+ physical disks1 in RAID10|N/A|N/A|
|Disk (Instance Storage)|N/A|N/A|Two physical disks in RAID1,or 4+ physical disks in RAID10|
|Disk Space|144 GB or greater|144 GB or greater|144 GB or greater|
|Network|1Gbps Private and Public|1Gbps Private and Public|1Gbps Private and Public

> (1) 10K SAS/SCSI RPM drives, or alternatively SSDs, may provide much better
performance for Cinder when allocating and destroying volumes.

## Software Requirements

Check the requirements below to ensure your environment is compatible.

### Operating System

OpenStack supports **Ubuntu Server Minimal 12.04 LTS**.

The SoftLayer Chef recipes make use of the [Ubuntu Cloud repository](https://wiki.ubuntu.com/ServerTeam/CloudArchive), which is where current OpenStack packages are maintained. The recipes automatically handle the configuration needed to use the Ubuntu Cloud repository.

### Chef

**Chef 11.4** or greater is required.

### Cookbooks

Have the following cookbooks handy before beginning the install process. You
can download them at [Opscode Cookbooks GitHub account](https://github.com
/opscode-cookbooks/mysql).

  * [partial_search](https://github.com/opscode-cookbooks/partial_search)
  * [mysql](https://github.com/opscode-cookbooks/mysql)
  * [ntp](https://github.com/opscode-cookbooks/ntp)
  * [build_essential](https://github.com/opscode-cookbooks/build-essential)
  * [openssl](https://github.com/opscode-cookbooks/openssl)

## Networking Requirements

Within the SoftLayer environment and the Chef cookbooks provided, the reference architecture consists of three separate networks (two physical interfaces and one virtual interface). Refer to the following diagram to determine how various components and are connected, and the networks they're connected to.

> Add gliffy image

For OpenStack private cloud deployments, we recommend following best practices to secure your public network, exposing only the systems and services that you wish to make available over the Internet.

Included below is a table you can use to reference each description and some important notes.

|Network|Description|Addressing|
| --- | --- | --- |
|Private|Existing SoftLayer back-end network where all your hardware exists, including VLANs attached to your account. Most SoftLayer servers are connected to this network on the **bond0** interface, but other servers may be connected on **eth0**. This provides access to other non-OpenStack servers and services on the SoftLayer private network.|You must order an IPv4 pool of Portable *Private* IPs to dole out across instances. See important info about IP addressing.
|Public|Existing SoftLayer front-end network from which all incoming Internet traffic is received and all outbound Internet traffic is sent. Most SoftLayer servers are connected to this network on the **bond1** interface, but other servers may be connected on **eth1**.|Must order an IPv4 pool of Portable _Public_ IPs to dole out across instances. See important info about IP addressing|
|Data|Networks created within OpenStack Quantum are part of the data network. OpenStack instances communicate with each other over the data network, including when they issue DHCP requests during boots and reboots. This network is an IP-over-GRE network between Network and Compute Nodes. The virtual network appliance used is Open vSwitch combined with the `quantum-plugin-openvswitch-agent` in Quantum.|Default environment attributes in our cookbooks allow you to create overlapping IPv4 subnet ranges between different tenants and projects. See important info about IP addressing.

### Important Information about IP Addressing

A minimum, but not recommended, range of /30 (or 4 total IP addresses with
**1** usable address) is required in order to use a SoftLayer Portable IP
block within your OpenStack private cloud, whether on the public network or
the private network. Whenever possible, we recommend using blocks larger than
/30.

As with all networks, the first IP in a subnet is reserved for addressing the
subnet, the second IP is already used by the upstream SoftLayer router (and in
many networks this is the case), and the final address in the subnet is used
for broadcast traffic.

With these constraints in mind, a /29 portable subnet would thusly provide six
total with three usable IP addresses, a /28 subnet would provide 14 total with
11 usable IP addresses, a /27 subnet would provide 30 total with 27 usable
addresses, and so forth.

Remember that the DHCP server used in Quantum will need an IP address on each
subnet where DHCP is enabled. Keep this in mind when planning how large of a
SoftLayer Portable IP block to order.

OpenStack utilizes NAT (Network Address Translation) across externally
connected Quantum/Neutron virtual routers. Any network that is attached to the
router then has external network access through NAT. The use of floating IP's
can reduce the size of the portable block you will have to purchase by
allowing all compute instances to have outbound network access when not
running inbound public services.

### IP Constraints on Data Networks

When creating new Data Networks to connect your instances, we recommend
limiting Data Network subnets to the following IP ranges:

  * 172.16.0.0/12 (or 172.16.0.0 - 172.31.255.255)
  * 192.168.0.0/16 (or 192.168.0.0 - 192.168.255.255)

Please note that any instance that is simultaneously connected to the
SoftLayer Private Network **and** Data Network subnet within
10.0.0.0/8 is very likely to conflict and cause unforeseen problems, since the
SoftLayer Private Network uses subnets within 10.0.0.0/8 as well.

If you absolutely need to create and use Data Network subnets within
10.0.0.0/8, ensure each instance assigned to them are not connected to the
SoftLayer Private Network.
