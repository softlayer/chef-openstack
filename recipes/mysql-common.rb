package 'apparmor' do
  action :purge
end

include_recipe 'chef-openstack::set_attributes'
include_recipe 'chef-openstack::set_cloudnetwork'
include_recipe 'mysql::server'
