include_recipe "grizzly::neutron-common"

bash "grant privilegies" do
	not_if "grep neutron /etc/sudoers"
	code <<-CODE
	echo "neutron ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	CODE
end

template "Neutron compute node config" do
	path "/etc/neutron/neutron.conf"
	owner "root"
	group "neutron"
	mode "0644"
	source "neutron/neutron.conf.erb"
	notifies :restart, resources(:service => "neutron-plugin-openvswitch-agent"), :immediately
	notifies :restart, resources(:service => "openvswitch-switch"), :immediately
end

