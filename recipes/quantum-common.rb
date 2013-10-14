%w[openvswitch-switch openvswitch-datapath-dkms quantum-plugin-openvswitch-agent openvswitch-datapath-source].each do |pkg|
	package pkg do
		action :install
	end
end

service "openvswitch-switch" do
	supports :status => true, :restart => true, :reload => true
	action :nothing
end

service "quantum-plugin-openvswitch-agent" do
	provider Chef::Provider::Service::Upstart
	action :nothing
end


template "Quantum network node OVS config" do
	path "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini"
	owner "root"
	group "quantum"
	mode "0644"
	source "quantum/ovs_quantum_plugin.ini.erb"
	notifies :restart, resources(:service => "quantum-plugin-openvswitch-agent"), :immediately
	notifies :restart, resources(:service => "openvswitch-switch"), :immediately
end

bash "create external bridge" do
	not_if("ovs-vsctl list-br | grep br-ex")
	code <<-CODE
	ovs-vsctl add-br br-ex
	CODE
end

bash "create softlayer private bridge" do
	not_if("ovs-vsctl list-br | grep br-priv")
	code <<-CODE
	ovs-vsctl add-br br-priv
	CODE
end

bash "create integration bridge" do
	not_if("ovs-vsctl list-br | grep br-int")
	code <<-CODE
	ovs-vsctl add-br br-int
	CODE
end

if node[:node_info][:is_bonded] == "True"
	template "/etc/network/interfaces" do
		owner "root"
		group "quantum"
		mode "0644"
		source "quantum/interfaces-bonded.erb"
	end
else
	template "/etc/network/interfaces" do
		owner "root"
		group "quantum"
		mode "0644"
		source "quantum/interfaces-nonbonded.erb"
	end
end

if node[:node_info][:private_dest] && node[:node_info][:private_via] 		
	#Private bridge configuration, Softlayer...etc.
	execute "Configure softlayer internal network bridge" do
	        not_if("ip addr show dev br-priv | grep #{node[:node_info][:private_ip]}")
			command "ip addr del #{node[:node_info][:private_ip]}/#{node[:node_info][:private_cidr]} dev #{node[:node_info][:private_iface]}; ip addr add #{node[:node_info][:private_ip]}/#{node[:node_info][:private_cidr]} dev br-priv;  ovs-vsctl add-port br-priv #{node[:node_info][:private_iface]}; ip link set dev br-priv up; route add -net #{node[:node_info][:private_dest]} gw #{node[:node_info][:private_via]} dev br-priv"
	        action :run
	end
else
	#Commodity Hardware/Virtual Machines
	execute "Configure other internal network bridge" do
	        not_if("ip addr show dev br-priv | grep #{node[:node_info][:private_ip]}")
			command "ip addr del #{node[:node_info][:private_ip]}/#{node[:node_info][:private_cidr]} dev #{node[:node_info][:private_iface]}; ip addr add #{node[:node_info][:private_ip]}/#{node[:node_info][:private_cidr]} dev br-priv;  ovs-vsctl add-port br-priv #{node[:node_info][:private_iface]}; ip link set dev br-priv up"
	        action :run
	end	
end

#Public bridge configuration
execute "Configure external network bridge" do
        not_if("ip addr show dev br-ex | grep #{node[:node_info][:public_ip]}")
		command "ip addr del #{node[:node_info][:public_ip]}/#{node[:node_info][:public_cidr]} dev #{node[:node_info][:public_iface]}; ip addr add #{node[:node_info][:public_ip]}/#{node[:node_info][:public_cidr]} dev br-ex; ovs-vsctl add-port br-ex #{node[:node_info][:public_iface]}; ip link set dev br-ex up; route add default gw #{node[:node_info][:default_gateway]} br-ex"
        action :run
end
