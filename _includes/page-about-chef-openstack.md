<div class="docs-section">
  {% if page.tag == "Grizzly" %}
    <h1 id="getting-started">Getting Started (Grizzly)</h1>
  {% elsif page.tag == "Havana" %}
    <h1 id="getting-started">Getting Started (Havana)</h1>
  {% endif %}

  <p>Our guide provides an overview for installing, configuring, deploying, and supporting OpenStack and Chef. Simply click any topic and
  get started.</p>

  <div class="row">
    <div class="col-12 col-lg-6">
      <h2><a href="#about_chef_and_openstack">About Chef and OpenStack</a></h2>
      <p><a href="#about_chef">About Chef</a></p>
      <p><a href="#about_openstack">About OpenStack</a></p>
    </div>

    <div class="col-12 col-lg-6">
      <h2><a href="#requirements">Requirements</a></h2>
      <p><a href="#node_requirements">Node Requirements</a></p>
      <p><a href="#software_requirements">Software Requirements</a></p>
      <p><a href="#networking_requirements">Networking Requirements</a></p>
    </div>
  </div>

  <div class="row">
    <div class="col-12 col-lg-6">
      <h2><a href="#installation">Installation</a></h2>
      <p><a href="#install_chef">Install Chef</a></p>
      <p><a href="#install_openstack">Install OpenStack</a></p>
      <p><a href="#bootstrap_your_nodes">Bootstrap Your Nodes</a></p>
      <p><a href="#chef_your_nodes">Chef Your Nodes</a></p>
    </div>

    <div class="col-12 col-lg-6">
      <h2><a href="#using_openstack">Using OpenStack</a></h2>
      <p><a href="#using_your_private_cloud">Using Your Private Cloud</a></p>
      <p><a href="#our_devops_tools">Using Our DevOps Tools</a></p>
      <p><a href="#scaling_and_branching_deployments">Scaling and Branching Deployments</a></p>
    </div>
  </div>

  <div class="row">
    <div class="col-12 col-lg-6">
      <h2><a href="#testing_openstack">Testing OpenStack</a></h2>
      <p><a href="#test_connectivity">Test Connectivity</a></p>
      <p><a href="#test_your_install">Test Your Install</a></p>
    </div>

    <div class="col-12 col-lg-6">
      <h2><a href="#allinone_sandbox">All-in-One Sandbox</a></h2>
      <p><a href="#create_your_own_sandbox">Create Your Own Sandbox</a></p>
      <p><a href="#introduction_to_vagrant">Introduction to Vagrant</a></p>
      <p><a href="#installation_process">Installation Process</a></p>
    </div>
  </div>

  <div class="row">
    <div class="col-12 col-lg-6">
      <h2><a href="#openstack_use_scenario">Use Scenario</a></h2>
      <p><a href="#softcube">SoftCube</a></p>
    </div>

    <div class="col-12 col-lg-6">
      <h2><a href="#finding_support_for_openstack">Find Support</a></h2>
      <p><a href="#technical_resources">Technical Resources</a></p>
      <p><a href="#definitions_for_components">Definitions for Components</a></p>
      <p><a href="#definitions_for_terms">Definitions for Terms</a></p>
    </div>
  </div>
</div>

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