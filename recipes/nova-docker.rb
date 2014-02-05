include_recipe 'chef-openstack::common'

kernel_version = node['kernel']['release'][0,3]

if kernel_version.to_f < 3.8
  raise 'Your kernel version must be at least "3.8".'  +
        "\nYour kernel version is \"#{kernel_version}\"." +
        "\nRun: sudo apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring"
end

bash "Add docker repository keys" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
  EOH
  action :nothing
end

template "/etc/apt/sources.list.d/docker.list" do
  source "docker/docker.list.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[apt-get clean]", :immediately
  notifies :run, "bash[Add docker repository keys]", :immediately
  notifies :run, "execute[apt-get update]", :immediately
end

packages = %w[lxc-docker
              nova-compute-lxc] 

packages.each do |pkg|
  package pkg do
    action :install
  end
end

service 'nova-compute' do
  provider Chef::Provider::Service::Upstart
  action :nothing
end

bash 'grant privileges' do
  not_if 'grep nova /etc/sudoers'
  code <<-CODE
  echo 'nova ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  CODE
end

template 'Nova compute api-paste' do
  path '/etc/nova/api-paste.ini'
  source 'nova/api-paste.ini.erb'
  owner 'nova'
  group 'nova'
  mode '0600'
  notifies :restart, resources(:service => 'nova-compute')
end

template 'Nova compute configuration' do
  path '/etc/nova/nova.conf'
  source 'nova/nova.conf.erb'
  owner 'nova'
  group 'nova'
  mode '0600'
  notifies :restart, resources(:service => 'nova-compute'), :immediately
end

include_recipe "chef-openstack::neutron-compute"
