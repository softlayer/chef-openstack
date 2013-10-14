#!/bin/bash

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

knife node run_list add openstack1.example.com 'role[grizzly-controller]'
knife node run_list add openstack2.example.com 'role[grizzly-compute]'
knife node run_list add openstack3.example.com 'role[grizzly-mysql-cinder]'
knife node run_list add openstack4.example.com 'role[grizzly-mysql-glance]'
knife node run_list add openstack5.example.com 'role[grizzly-mysql-keystone]'
knife node run_list add openstack6.example.com 'role[grizzly-mysql-quantum]'
knife node run_list add openstack7.example.com 'role[grizzly-mysql-nova]'
knife node run_list add openstack8.example.com 'role[grizzly-network]'
knife node run_list add openstack9.example.com 'role[grizzly-rabbitmq]'
knife node run_list add openstack10.example.com 'role[grizzly-cinder]'
knife node run_list add openstack11.example.com 'role[grizzly-keystone]'
knife node run_list add openstack12.example.com 'role[grizzly-glance]'