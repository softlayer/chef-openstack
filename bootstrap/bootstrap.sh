#!/bin/bash
#Example with all components separated.  Edit to model your desired configuration.

knife bootstrap openstack1.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack2.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack3.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack4.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack5.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack6.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack7.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack8.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack9.example.com  -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack10.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack11.example.com -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION
knife bootstrap openstack12.example.com  -x YOUR_USER --sudo -i /home/YOUR_USER/.ssh/id_rsa -E YOUR_REGION

knife node run_list add openstack1.example.com 'recipe[chef-openstack::mysql-glance]'
knife node run_list add openstack2.example.com 'recipe[chef-openstack::mysql-cinder]'
knife node run_list add openstack3.example.com 'recipe[chef-openstack::mysql-keystone]'
knife node run_list add openstack4.example.com 'recipe[chef-openstack::mysql-nova]'
knife node run_list add openstack5.example.com 'recipe[chef-openstack::mysql-neutron]'
knife node run_list add openstack6.example.com 'recipe[chef-openstack::rabbitmq-server]'
knife node run_list add openstack7.example.com 'recipe[chef-openstack::keystone]'
knife node run_list add openstack8.example.com 'recipe[chef-openstack::controller]'
knife node run_list add openstack9.example.com 'recipe[chef-openstack::cinder]'
knife node run_list add openstack10.example.com 'recipe[chef-openstack::glance]'
knife node run_list add openstack11.example.com 'recipe[chef-openstack::neutron-network]'
knife node run_list add openstack12.example.com 'recipe[chef-openstack::nova-kvm]'
