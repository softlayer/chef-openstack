template "/etc/sysctl.conf" do
	source "ip_forwarding/sysctl.conf.erb"
	owner "root"
	group "root"
	mode "0644"
end

bash "enable ip forwarding" do
	code <<-CODE
	sysctl net.ipv4.ip_forward=1
	CODE
	not_if "grep \"net.ipv4.ip_forward=1\" /etc/sysctl.conf"
end
