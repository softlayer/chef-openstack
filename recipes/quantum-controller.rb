%w[quantum-server].each do |pkg|
	package pkg do 
		action :install
	end
end

service "quantum-server" do
	action :nothing
end

template "Quantum controller api-paste config" do
	path "/etc/quantum/api-paste.ini"
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/api-paste.ini.erb"
	notifies :restart, resources(:service => "quantum-server")
end

bash "grant privilegies" do
	not_if "grep quantum /etc/sudoers"
	code <<-CODE
	echo "quantum ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	CODE
end

template "OVS controller configuration" do
	path "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini"
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/ovs_quantum_plugin.ini.erb"
	notifies :restart, resources(:service => "quantum-server")
end

template "Quantum controller configuration" do
	path "/etc/quantum/quantum.conf"
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/quantum.conf.erb"
	notifies :restart, resources(:service => "quantum-server"), :immediately
end

bash "Enable the controller OVS plugin" do
	not_if {File.symlink?('/etc/quantum/plugin.ini')}
	code <<-CODE
		ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini
	CODE
end