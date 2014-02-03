include_recipe 'chef-openstack::mysql-common'

bash 'create database for neutron' do
  not_if("mysql -uroot -p#{node['mysql']['server_root_password']} -e 'SHOW DATABASES' | grep #{node['neutron']['db']['name']}")
  code <<-CODE
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE #{node['neutron']['db']['name']};"
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node['neutron']['db']['name']}.* TO '#{node['neutron']['db']['username']}'@'localhost' IDENTIFIED BY '#{node['neutron']['db']['password']}';"
    mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node['neutron']['db']['name']}.* TO '#{node['neutron']['db']['username']}'@'#{node[:controller][:private_ip]}' IDENTIFIED BY '#{node['neutron']['db']['password']}';"
  CODE
  notifies :restart, resources(:service => 'mysql'), :immediately
end
