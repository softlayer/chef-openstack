include_recipe 'chef-openstack::apparmor'
include_recipe 'mysql::server'

bash 'create database for nova' do
  not_if("mysql -uroot -p#{node['mysql']['server_root_password']} -e 'SHOW DATABASES' | grep #{node['nova']['db']['name']}")
  code <<-CODE
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE #{node['nova']['db']['name']};"
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node['nova']['db']['name']}.* TO '#{node['nova']['db']['username']}'@'localhost' IDENTIFIED BY '#{node['nova']['db']['password']}';"
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node['nova']['db']['name']}.* TO '#{node['nova']['db']['username']}'@'#{node[:controller][:private_ip]}' IDENTIFIED BY '#{node['nova']['db']['password']}';"
  CODE
  notifies :restart, resources(:service => 'mysql'), :immediately
end
