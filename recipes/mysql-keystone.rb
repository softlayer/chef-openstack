include_recipe "chef-openstack::apparmor"
include_recipe "mysql::server"

bash "create database for keystone" do
	not_if("mysql -uroot -p#{node['mysql']['server_root_password']} -e 'SHOW DATABASES' | grep #{node["keystone"]["db"]["name"]}")
		code <<-CODE
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE #{node["keystone"]["db"]["name"]};"
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node["keystone"]["db"]["name"]}.* TO '#{node["keystone"]["db"]["username"]}'@'localhost' IDENTIFIED BY '#{node["keystone"]["db"]["password"]}';"
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node["keystone"]["db"]["name"]}.* TO '#{node["keystone"]["db"]["username"]}'@'#{node[:keystone][:private_ip]}' IDENTIFIED BY '#{node["keystone"]["db"]["password"]}';"
		CODE
end
