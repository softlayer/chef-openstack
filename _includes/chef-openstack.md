# About Chef and OpenStack

The open source configuration management and automation framework used to deploy and manage many large public and private installations supports a wide variety of deployment scenarios. This section introduces each resource, followed by supplementing documentation.

## About Chef

Chef is a systems integration framework built to bring the benefits of configuration management to your entire infrastructure. This framework makes it easy to deploy servers and applications to any physical, virtual, or cloud location, no matter the size of the infrastructure.

Each organization is composed of one (or more) workstations, a single server, and every node configured and maintained by a Chef client. Install Chef client on every node and it will perform all necessary configuration tasks. Then come cookbooks and recipes. The Chef client relies on these to tell it how to configure each node in your organization. You can even manage multiple environments—-or groups of nodes and settings—-with the same Chef server. Visit [https://learnchef.opscode.com](https://learnchef.opscode.com) for more information.

<img class="img-thumbnail" id="no-height" src="{{ page.baseurl }}img/chef-openstack/001.jpg">

## About OpenStack

OpenStack is a free, open-source project that provides an infrastructure as a service (IaaS) for cloud computing. Backed by a vibrant community of both individuals and companies, its technology consists of a series of interrelated projects that manage pools of coordination, processing, storage, and networking throughout a data center.

OpenStack’s ability to empower deployers and administrators, manage resources through its web interface, and provide easy-to-use command-line tools has helped it gain a lot of traction in only a few short years.

Visit [http://docs.openstack.org](http://docs.openstack.org) for more information.