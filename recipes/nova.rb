packages = %w[nova-api
              nova-cert
              nova-common
              nova-conductor
              nova-scheduler
              nova-consoleauth
              python-nova
              python-novaclient
              novnc]
services = %w[nova-cert
              nova-api
              nova-scheduler
              nova-conductor
              nova-consoleauth
              nova-novncproxy]

packages.each do |pkg|
  package pkg do
    action :install
  end
end

services.each do |srv|
  service srv do
    provider Chef::Provider::Service::Upstart
    action :nothing
  end
end

package 'nova-novncproxy' do
  action :install
  notifies :restart, resources(:service => 'nova-novncproxy'), :immediately
end

bash 'grant privileges' do
  not_if 'grep nova /etc/sudoers'
  code <<-CODE
  echo 'nova ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  CODE
end

execute 'nova-manage db sync' do
  command 'nova-manage db sync'
  action :nothing
end

template '/etc/nova/api-paste.ini' do
  source 'nova/api-paste.ini.erb'
  owner 'nova'
  group 'nova'
  mode '0600'
  notifies :run, resources(:execute => 'nova-manage db sync')

  services.each do |svc|
    notifies :restart, resources(:service => svc), :immediately
  end
end

template '/etc/nova/nova.conf' do
  source 'nova/nova.conf.erb'
  owner 'nova'
  group 'nova'
  mode '0600'
  notifies :run, resources(:execute => 'nova-manage db sync'), :immediately

  services.each do |svc|
    notifies :restart, resources(:service => svc), :immediately
  end
end
