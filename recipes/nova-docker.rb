include_recipe 'chef-openstack::common'

kernel_version = node['kernel']['release'][0,2]

if kernel_version < 3.8
  raise 'Your kernel version must be at least 3.8'
end

bash "Add docker repository keys" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
  EOH
end

template "/etc/apt/sources.list.d/docker.list" do
  source "docker/docker.list.erb"
  owner "root"
  group "root"
  mode "0644"
end

execute 'apt-get clean' do
  action :nothing
end

execute 'apt-get update' do
  action :nothing
end

package "lxc-docker" do
  action :install
end