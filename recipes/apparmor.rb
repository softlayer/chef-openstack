#If a non-standard data directory is chosen, we need to reconfigure apparmor
# service "apparmor" do
# 	supports :status => true, :restart => true, :reload => true
# 	action :nothing
# end

# template "/etc/apparmor.d/local/usr.sbin.mysqld" do
# 	source "mysql/usr.sbin.mysqld.erb"
# 	owner "root"
# 	group "root"
# 	mode 00644
# 	not_if "grep \"#{node['mysql']['data_dir']}\" /etc/apparmor.d/usr.sbin.mysqld"
# 	notifies :reload, resources(:service => "apparmor"), :immediately
# end

package "apparmor" do
	action :purge
end
