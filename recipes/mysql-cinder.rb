include_recipe "chef-openstack::apparmor"
include_recipe "mysql::server"

bash "create database for cinder" do
	not_if("mysql -uroot -p#{node['mysql']['server_root_password']} -e 'SHOW DATABASES' | grep #{node["cinder"]["db"]["name"]}")
		code <<-CODE
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE #{node["cinder"]["db"]["name"]};"
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node["cinder"]["db"]["name"]}.* TO '#{node["cinder"]["db"]["username"]}'@'localhost' IDENTIFIED BY '#{node["cinder"]["db"]["password"]}';"
			mysql -uroot -p#{node['mysql']['server_root_password']} -e "GRANT ALL PRIVILEGES ON #{node["cinder"]["db"]["name"]}.* TO '#{node["cinder"]["db"]["username"]}'@'#{node[:cinder][:private_ip]}' IDENTIFIED BY '#{node["cinder"]["db"]["password"]}';"
		CODE
end