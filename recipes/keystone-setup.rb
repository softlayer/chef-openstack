# Load Keystone attributes users hash
node['keystone']['default_accounts']['users'].each do |user_name, info|
  chef_openstack_keystone "Create keystone user: #{user_name}" do
    action :create_user
    env Stack.keystone_service_env(node)
    password info['password']
    email info['email']
    user user_name
  end
end

# Load Keystone attributes tenants array
node['keystone']['default_accounts']['tenants'].each do |tenant_name|
  chef_openstack_keystone "Create Keystone tenant: #{tenant_name}" do
    action :create_tenant
    env Stack.keystone_service_env(node)
    tenant tenant_name
  end
end

# Load Keystone attributes roles array
node['keystone']['default_accounts']['roles'].each do |role_name|
  chef_openstack_keystone "Create Keystone role: #{role_name}" do
    action :create_role
    env Stack.keystone_service_env(node)
    role role_name
  end
end

node['keystone']['default_accounts']['services'].each do |service, info|
  chef_openstack_keystone "Create Keystone service: #{service}" do
    action :create_service
    env Stack.keystone_service_env(node)
    name service
    service_type info['type']
    description info['description']
  end
end

node['keystone']['default_accounts']['user-roles'].each do |user_role|
  chef_openstack_keystone "Create Keystone role: #{user_role}" do
    action :user_role_add
    env Stack.keystone_service_env(node)
    user user_role['user']
    tenant user_role['tenant']
    role user_role['role']
  end
end

chef_openstack_keystone 'Create endpoint for Nova' do
  action :create_endpoint
  env Stack.keystone_service_env(node)
  region node.chef_environment
  internal_url "http://#{node[:controller][:private_ip]}:8774/v2/$(tenant_id)s"
  public_url "http://#{node[:controller][:private_ip]}:8774/v2/$(tenant_id)s"
  admin_url "http://#{node[:controller][:private_ip]}:8774/v2/$(tenant_id)s"
  service_type 'nova'
end

chef_openstack_keystone 'Create endpoint for Cinder' do
  action :create_endpoint
  env Stack.keystone_service_env(node)
  region node.chef_environment
  internal_url "http://#{node[:cinder][:private_ip]}:8776/v1/$(tenant_id)s"
  public_url "http://#{node[:cinder][:private_ip]}:8776/v1/$(tenant_id)s"
  admin_url "http://#{node[:cinder][:private_ip]}:8776/v1/$(tenant_id)s"
  service_type 'cinder'
end

chef_openstack_keystone 'Create endpoint for Glance' do
  action :create_endpoint
  env Stack.keystone_service_env(node)
  region node.chef_environment
  internal_url "http://#{node[:glance][:private_ip]}:9292/v2"
  public_url "http://#{node[:glance][:private_ip]}:9292/v2"
  admin_url "http://#{node[:glance][:private_ip]}:9292/v2"
  service_type 'glance'
end


chef_openstack_keystone 'Create endpoint for Keystone' do
  action :create_endpoint
  env Stack.keystone_service_env(node)
  region node.chef_environment
  internal_url "http://#{node[:keystone][:private_ip]}:5000/v2.0"
  public_url "http://#{node[:keystone][:private_ip]}:5000/v2.0"
  admin_url "http://#{node[:keystone][:private_ip]}:35357/v2.0"
  service_type 'keystone'
end

chef_openstack_keystone 'Create endpoint for EC2' do
  action :create_endpoint
  env Stack.keystone_service_env(node)
  region node.chef_environment
  internal_url "http://#{node[:controller][:private_ip]}:8773/services/Cloud"
  public_url "http://#{node[:controller][:private_ip]}:8773/services/Cloud"
  admin_url "http://#{node[:controller][:private_ip]}:8773/services/Admin"
  service_type 'ec2'
end

chef_openstack_keystone 'Create endpoint for Neutron' do
  action :create_endpoint
  env Stack.keystone_service_env(node)
  region node.chef_environment
  internal_url "http://#{node[:controller][:private_ip]}:9696/"
  public_url "http://#{node[:controller][:private_ip]}:9696/"
  admin_url "http://#{node[:controller][:private_ip]}:9696/"
  service_type 'neutron'
end
