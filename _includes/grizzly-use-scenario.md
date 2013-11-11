# OpenStack Use Scenario

OpenStack is a cloud-computing project. It allows the implementer to create a private datacenter and provides everything needed for a
private cloud experience:

*   Virtual Machines/Instances
*   Block Storage
*   Networking

While it&#8217;s very time-consuming to set up manually on your own, our Chef recipes make it simple to get up and running quickly. As
an example, let&#8217;s look at fictional company called SoftCube.

## SoftCube

SoftCube is a new startup. They expect a large boom in new customers and need the ability to adjust quickly to a changing set of
requirements. Using a private cloud will provide them with the flexibility and adaptability that they need. To make this happen, SoftCube
needs to move three of their existing hardware servers to the cloud. Currently, they have two web servers and one database server.

<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/017.png">

These servers reside on-site and neither of them have redundant power or networking. Let&#8217;s get them moved to the SoftLayer Private
Cloud that SoftCube just decided to purchase.

SoftCube will need OpenStack compute instances to replace their hardware servers. SoftCube is a security-conscious company, they will
use key-based <span class="caps">SSH</span> authentication to access their compute instances—the default behavior for new compute instances
in OpenStack. But, before creating these instances, we&#8217;ll need to create the <span class="caps">SSH</span> key that will be used to
access them. Then, each time SoftCube creates a new instance, OpenStack can inject the <span class="caps">SSH</span> key, and they&#8217;ll
use the key each time they need to log in to one of their servers.

## Create an <span class="caps">SSH</span> Key

To create an <span class="caps">SSH</span> key, you&#8217;ll follow these simple steps in the Horizon dashboard.

<ol>
<li>Log in to the Horizon dashboard running on SoftCube&#8217;s new SoftLayer Private Cloud.</li>
<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/006.png">
<li>Click on the &#8220;Project&#8221; tab.</li>
<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/016.png">
<li>Select your Current Project (admin in this case).</li>
<li>Click &#8220;Access &amp; Security&#8221;.</li>
<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/001.png">
<li>Click the &#8220;Keypairs&#8221; tab.</li>
<li>Click &#8220;Create Keypair&#8221;.</li>
<li>Name the new keypair &#8220;SoftCube-Admin&#8221; and click the blue &#8220;Create Keypair&#8221; button.</li>
<li>Now that the keypair is created, download it by clicking the provided link if it does not start automatically.</li>
</ol>

### Create Compute Instances

Now that SoftCube&#8217;s keypair is available, the compute instances can be created.

<ol>
<li>Click on the &#8220;Project&#8221; tab.</li>
<li>Select your Current Project (admin in this case).</li>
<li>Click &#8220;Instances&#8221;.</li>
<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/010.png">
<li>Click the &#8220;Launch Instances&#8221; button.</li>
<li>A new dialog window will appear with all the details needed for launching a new compute instance. In the launch instance window, they
  will need the following information handy to create and launch their instances: (1) Image type, (2) Name, (3) Flavor, (4) Keypair, and
  (5) Network information. Additional volume and post-creation options may be needed in SoftCube&#8217;s future, but are not necessary to
  specify right now.</li>
<li>On the &#8220;Details&#8221; tab, provide these options.</li>
<ul>
<li>Instance Source: Image</li>
<li>Image: Ubuntu 12.04 Server (Cloud) amd64</li>
<li>Instance Name: web1.softcube.com</li>
<li>Flavor: m1.medium</li>
</ul>
<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/004.png">
<li>Click on the &#8220;Access &amp; Security&#8221; tab.</li>
<ul>
<li>&#8220;SoftCube-Admin&#8221; should be already selected as the <span class="caps">SSH</span> key, but if not, select it from the list.</li>
<li>Uncheck the &#8220;default&#8221; security group.</li>
<li>Check the &#8220;basic-ssh-icmp&#8221; security group.</li>
</ul>
<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/012.png">
</ol>

### Configure Network Access

SoftCube&#8217;s web servers will need both internet access and private network access with each other. They&#8217;ve decided to use
floating IPs in OpenStack to handle inbound public access to their web servers, private network access for all three servers, and no public
network access to their database server. This network setup requires each web server to have two network connections, as illustrated
below.

<ol>
  <li>Click on the &#8220;Networking&#8221; tab.</li>
<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/005.png">
<li>In the &#8220;Available Networks&#8221; list, click the &#8220;+&#8221; button next to &#8220;stack-network&#8221; and
  &#8220;softlayer-private&#8221;.</li>
<li>Click the &#8220;Launch&#8221; button. The first web server will be launched. Since SoftCube needs two web servers, follow the same
  steps to create a second web server with the name web2.softcube.com.</li>
<li>Lastly, they&#8217;ll need an instance for the database server. Since SoftCube wants to plan for growth as early as possible, they
  will tweak a few changes to the instance configuration.</li>
<li>On the &#8220;Details&#8221; tab, provide these options:

    <ul>
      <li>Instance name: db.softcube.com</li>

      <li>Flavor: m1.large (for a beefier amount of compute power)</li>
    </ul>
  </li>

  <li>On the &#8220;Access &amp; Security&#8221; tab, provide the same options as your web server.

    <ul>
      <li>On the &#8220;Networking&#8221; tab under &#8220;Available Networks&#8221;, click the &#8220;+&#8221; button next to
      &#8220;softlayer-private&#8221;.</li>

      <li>Click the &#8220;Launch&#8221; button. Within seconds, the database instance will launch, and SoftCube will be on the private
      cloud!</li>
    </ul>
  </li>
</ol>

### Allocate Public IP Addresses

We&#8217;re getting closer, but we aren&#8217;t quite finished yet. Each web server will need a public IP for inbound public access.
Currently, the compute instances are only accessible via the devices connected to OpenStack Quantum/Neutron network, or any device that is
on the SoftLayer Private Network. SoftCube can allocate public IP addresses purchased from SoftLayer to any instance at any time by
assigning Floating IPs, which is our next step.

<ol>
  <li>From the Instances list, click the &#8220;More&#8221; dropdown for web1.softcube.com.</li>

  <li>Click &#8220;Associate Floating IP&#8221;.</li>

<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/003.png">

  <li>Currently SoftCube has no allocated Floating IPs. One will need to be allocated before it will before it can be assigned to a compute
  instance. Click the &#8220;+&#8221; button to associate a floating IP with the current project.</li>

<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/013.png">

  <li>We need floating IPs provided to us from the &#8220;softlayer-public&#8221; network, so ensure it is selected as the Pool, and click
  the &#8220;Allocate IP&#8221; button.</li>

  <li>The Manage Floating IP Associations dialog box will appear with a public IP address pre-populated. Ensure the web1.softcube.com
  server is selected as well, and click &#8220;Associate&#8221;.</li>

<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/014.png">

  <li>Horizon will attach the new public IP address to the web1.softcube.com instance, and display it in the &#8220;IP Address&#8221;
  column in the instances list. Sometimes this may take a moment to update, but by this time the IP address has already been routed to the
  instance.</li>

<img class="img-thumbnail" src="{{ page.baseurl }}img/use-scenario/015.png">

  <li>Follow the same steps above to allocate another floating IP address to web2.softcube.com.</li>
</ol>

### Final Touches

SoftCube now has three OpenStack compute instances:

*   Two web servers with public inbound access
*   One database server that is accessible only on the backend

At this point, they can start transitioning their aging, hardware-based web and database servers to their new OpenStack instances.

Looks like SoftCube is well on its way to a successful future in the private cloud.