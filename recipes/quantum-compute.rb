include_recipe "chef-openstack::quantum-common"

bash "grant privilegies" do
	not_if "grep quantum /etc/sudoers"
	code <<-CODE
	echo "quantum ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	CODE
end

template "Quantum compute node config" do
	path "/etc/quantum/quantum.conf"
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/quantum.conf.erb"
	notifies :restart, resources(:service => "quantum-plugin-openvswitch-agent"), :immediately
	notifies :restart, resources(:service => "openvswitch-switch"), :immediately
end

