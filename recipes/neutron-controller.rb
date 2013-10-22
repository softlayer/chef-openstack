%w[neutron-server python-neutronclient].each do |pkg|
  package pkg do
    action :install
  end
end

service 'neutron-server' do
  action :nothing
end

template 'Neutron controller api-paste config' do
  path '/etc/neutron/api-paste.ini'
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/api-paste.ini.erb'
  notifies :restart, resources(:service => 'neutron-server')
end

bash 'grant privileges' do
  not_if 'grep neutron /etc/sudoers'
  code <<-CODE
  echo 'neutron ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  CODE
end

template 'OVS controller configuration' do
  path '/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini'
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/ovs_neutron_plugin.ini.erb'
  notifies :restart, resources(:service => 'neutron-server')
end

template 'Neutron controller configuration' do
  path '/etc/neutron/neutron.conf'
  owner 'root'
  group 'neutron'
  mode '0644'
  source 'neutron/neutron.conf.erb'
  notifies :restart, resources(:service => 'neutron-server'), :immediately
end
