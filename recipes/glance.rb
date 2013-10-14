
%w[glance glance-api glance-registry python-glanceclient glance-common python-mysqldb ].each do |pkg|
	package pkg do
		action :install
	end
end

bash "synchronize glance database" do
	code <<-CODE
		glance-manage db_sync
	CODE
	action :nothing
end

service "glance-registry" do
	provider Chef::Provider::Service::Upstart
	action :nothing 
end

service "glance-api" do
	provider Chef::Provider::Service::Upstart
	action :nothing
end

template "/etc/glance/glance-registry.conf" do
	source "glance/glance-registry.conf.erb"
	owner "glance"
	group "glance"
	mode "0644"
	notifies :restart, resources(:service => "glance-registry"), :immediately
end

template "/etc/glance/glance-api.conf" do
	source "glance/glance-api.conf.erb"
	owner "glance"
	group "glance"
	mode "0644"
	notifies :run, resources(:bash => "synchronize glance database"), :immediately
	notifies :restart, resources(:service => "glance-api"), :immediately
end

template "/etc/glance/glance-cache.conf" do
	source "glance/glance-cache.conf.erb"
	owner "glance"
	group "glance"
	mode "0644"
end

template "/etc/glance/glance-scrubber.conf" do
	source "glance/glance-scrubber.conf.erb"
	owner "glance"
	group "glance"
	mode "0644"
end

template "/root/.openrc" do
	source "keystone/openrc.erb"
	owner "root"
	group "root"
	mode "0600"
end


#set from attributes file
node["glance"]["images"].each do | name, image |

	execute "Queue \"#{name}\" to glance." do
		command "glance image-create --is-public true --disk-format qcow2 --container-format bare --name \"#{name}\" --copy-from #{image}"
		environment "OS_USERNAME" => "admin",
					"OS_PASSWORD" => node[:admin][:password],
					"OS_TENANT_NAME" => "admin",
					"OS_AUTH_URL"  => "http://#{node[:keystone][:private_ip]}:#{node["keystone"]["config"]["public_port"]}/v2.0"
					
		#not_if "glance -f image-show \"#{name.to_s}\""
		not_if "glance -f image-list | grep \"#{name.to_s}\""
	end

end