service "rabbitmq-server" do
	supports :status => true, :restart => true, :reload => true
	action :nothing
end

package "rabbitmq-server" do
	action :install
	notifies :restart, resources(:service => "rabbitmq-server"), :immediately
end