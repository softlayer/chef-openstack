%w[python-software-properties software-properties-common].each do |pkg|
	package pkg do
		action :install
	end
end

execute "apt-get clean" do
	action :nothing
end

execute "apt-get update" do
	action :nothing
end

execute "apt-get upgrade -y" do
	action :nothing
end

package "ubuntu-cloud-keyring" do
	action :nothing
end

execute "add cloud repo" do
	not_if "grep ubuntu-cloud /etc/apt/sources.list"
	command "add-apt-repository 'deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main'"
	action :run
	notifies :install, resources(:package => "ubuntu-cloud-keyring"), :immediately
	notifies :run, resources(:execute => "apt-get clean"), :immediately
	notifies :run, resources(:execute => "apt-get update"), :immediately
	notifies :run, resources(:execute => "apt-get upgrade -y"), :immediately
end

#Proposed and Havana testing
# execute "add cloud repo" do
# 	command "add-apt-repository 'deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/havana main'"
# 	action :run
# end


%w[linux-headers-generic curl vim ipcalc traceroute iotop sysstat].each do |pkg|
	package pkg do
		action :install
	end
end
