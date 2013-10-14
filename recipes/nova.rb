%w[nova-api nova-cert nova-common nova-conductor nova-scheduler python-nova python-novaclient nova-consoleauth novnc].each do |pkg|
	package pkg do
		action :install
	end
end

%w[nova-cert nova-api nova-scheduler nova-conductor nova-consoleauth nova-novncproxy].each do |srv|
	service srv do
		provider Chef::Provider::Service::Upstart
		action :nothing
	end
end

package "nova-novncproxy" do
	action :install
	notifies :restart, resources(:service => "nova-novncproxy"), :immediately
end

bash "grant privilegies" do
	not_if "grep nova /etc/sudoers"
	code <<-CODE
	echo "nova ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	CODE
end

execute "nova-manage db sync" do
  command "nova-manage db sync"
  action :nothing
end

template "/etc/nova/api-paste.ini" do
	source "nova/api-paste.ini.erb"
	owner "nova"
	group "nova"
	mode "0600"
	notifies :run, resources(:execute => "nova-manage db sync")
	notifies :restart, resources(:service => "nova-cert")
	notifies :restart, resources(:service => "nova-api")
	notifies :restart, resources(:service => "nova-scheduler")
	notifies :restart, resources(:service => "nova-conductor")
	notifies :restart, resources(:service => "nova-novncproxy")
	notifies :restart, resources(:service => "nova-consoleauth")
end

template "/etc/nova/nova.conf" do
	source "nova/nova.conf.erb"
	owner "nova"
	group "nova"
	mode "0600"
	notifies :run, resources(:execute => "nova-manage db sync"), :immediately	
	notifies :restart, resources(:service => "nova-cert"), :immediately
	notifies :restart, resources(:service => "nova-api"), :immediately
	notifies :restart, resources(:service => "nova-scheduler"), :immediately
	notifies :restart, resources(:service => "nova-conductor"), :immediately
	notifies :restart, resources(:service => "nova-novncproxy"), :immediately
	notifies :restart, resources(:service => "nova-consoleauth"), :immediately
end


#Multiworker conductor configuration
template "Nova conductor upstart" do
	path "/etc/init/nova-conductor-multi.conf"
	source "nova/nova-conductor-multi.conf.erb"
	owner "root"
	group "root"
	mode 00644
end

template "Nova conductor upstart worker" do
	path "/etc/init/nova-conductor-worker.conf"
	source "nova/nova-conductor-worker.conf.erb"
	owner "root"
	group "root"
	mode 00644
end

service "nova-conductor-multi" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
	provider Chef::Provider::Service::Upstart
end