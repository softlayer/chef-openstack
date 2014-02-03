include_recipe 'chef-openstack::common'
include_recipe "chef-openstack::neutron-controller"
include_recipe "chef-openstack::nova-controller"
include_recipe "chef-openstack::dashboard"
