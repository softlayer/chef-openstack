include_recipe "chef-openstack::apparmor"
include_recipe "mysql::server"

bash "create database for quantum" do
	not_if("mysql -uroot -p#{node['mysql']['server_root_password']} -e 'SHOW DATABASES' | grep #{node["quantum"]["db"]["name"]}")
		code <<-CODE
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE #{node["quantum"]["db"]["name"]};"
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node["quantum"]["db"]["name"]}.* TO '#{node["quantum"]["db"]["username"]}'@'localhost' IDENTIFIED BY '#{node["quantum"]["db"]["password"]}';"
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node["quantum"]["db"]["name"]}.* TO '#{node["quantum"]["db"]["username"]}'@'#{node[:controller][:private_ip]}' IDENTIFIED BY '#{node["quantum"]["db"]["password"]}';"
		CODE
		notifies :restart, resources(:service => 'mysql'), :immediately
end
