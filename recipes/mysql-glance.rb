include_recipe 'chef-openstack::apparmor'
include_recipe 'mysql::server'

bash 'create database for glance' do
  not_if("mysql -uroot -p#{node['mysql']['server_root_password']} -e 'SHOW DATABASES' | grep #{node['glance']['db']['name']}")
  code <<-CODE
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE #{node['glance']['db']['name']};"
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node['glance']['db']['name']}.* TO '#{node['glance']['db']['username']}'@'localhost' IDENTIFIED BY '#{node['glance']['db']['password']}';"
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node['glance']['db']['name']}.* TO '#{node['glance']['db']['username']}'@'#{node[:glance][:private_ip]}' IDENTIFIED BY '#{node['glance']['db']['password']}';"
  CODE
  notifies :restart, resources(:service => 'mysql'), :immediately
end
