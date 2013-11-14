# Open Requests

The following requests are bundled by where they reside in priority. Moreover, none of them are complete or currently being worked on. 

## Top Priority

These requests fall under the general definition of incomplete, confusing, or unclear content.

* Name "Start Using OpenStack" something like "Validate Your Install" and focus on the basic validation of the environment. 
* Before "About OpenStack" and "About Chef", add an "About this Guide" to lay out its purpose. Include: When I am done, what do I have? What will be created?" A picture would be nice.
* All the disk storage in the node requirements tables is a little confusing.
* Before the "Installing OpenStack" section, add a "Provision the Resources”. Be explicit on what is needed and what they would be used for. "Before going on in this guide, ensure you have the following resources in your account..." and then tell them what they need to provision i.e. at least 3 hardware nodes with Ubuntu, private portable subnet, public portable subnet, etc.
* "Install OpenStack" - this section is confusing, these appear to be general steps that are just saying how the flow will work, but I also felt like I should have been doing something as I read them and looked at the samples (especially because of step 5 on page 11)?
* Prepare chef for OpenStack deployment - where do I run these commands?
* Bootstrap your nodes says, "It is recommended to use the bootstrap scripts." but whose? Yours of chefs? Then it says "Edit the script" .. But what script?
* "Note: Log in with the admin user name and the password you created during the OpenStack Chef Deployment." ...unless I missed it, don't recall setting a password earlier.

## Standard Priority

Requests here are not mission-critical, but do add clarity and usability.

* [@morourke](https://github.com/caleorourke) Add less to minify css output and easier coding
* [@morourke](https://github.com/caleorourke) Show the latest release versions on the landing page (ex. http://getbootstrap.com)
* [@morourke](https://github.com/caleorourke) Show when the last update was committed to GitHub on the landing page (ex. http://foundation.zurb.com)
* [@morourke](https://github.com/caleorourke) Add GitHub social links back to footer. Do not include Twitter (PI doesn't have control over Twitter).
* [@morourke](https://github.com/caleorourke) Let users know they can get notifications by watching our repo.
* Point to docs that explain how to create A records and do DNS management at SoftLayer
* "Using Our DevOps Tools" seems a little out of place alongside user content. It deserves a mention, but maybe a paragraph on key functions and a link off to more details. Content provided didn't make it clear why i would want it with my OpenStack install.
* Drop "THE SWFTP-CHEF COOKBOOK". Swift is not installed in this from what I see.
* How do I allocate public and private IP range and add them to my environment?

## No Priority

Priorities have not been defined yet for these request. Most are likely to be open-ended requests that need vetting first.

* Any reason you don't recommend 10GBe on the network node?
* One thing to consider is calling out Cinder as a separate node type (i.e. bare metal with lots of HDDs and 10GBe)
* Under Install Chef, have a dedicated chef node called out earlier, such as a CCI? Not clear from this if I am running on one of those three nodes from page 5 or somewhere else?
* Could the mysql and rabbitmq nodes discussion be placed in an "advanced configs" section?
* Is glance pre-populated with those images? The same goes for keystone. Is it pre-populated with demo?
* Explain how to use your public Swift to back Glance and the pros/cons
* Update social.html in _includes (all repos)
* Update resources.md in _root (all repos)
* Update all files in _includes for sidenav
* Inject references.md file into Getting Started page
* Add stackedit editor to each repo for quick local editing

## Open for Debate

* Stay away from any user-centric content
* Explain how to use QuantaStor as a volume server
* OpenStack Use Scenarios - I didn't find much value here. There are lots of OpenStack "How To" type guides for users. A better use of time/energy will be focusing on the admin/deploy, "As an admin, how do I deploy OpenStack on SoftLayer in the best way possible" - i.e. give them the options, what they can do, tradeoffs, and how to enable each.

# In-Flight

* [@morourke](https://github.com/caleorourke) Find out why responsiveness on mobile devices isn't complying with the viewport settings.

# Done

* [@morourke](https://github.com/caleorourke) Transition the role and quantum/neutron changes into the current docs
* [@morourke](https://github.com/caleorourke) Improve load time by adding js for typekit fonts locally in the header
* [@morourke](https://github.com/caleorourke) Test maruku upgrade in hope of converting html back to md