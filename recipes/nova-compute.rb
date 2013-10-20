if node[:node_info][:is_vm] == 'True'
  package 'nova-compute-qemu' do
    action :install
  end
else
  package 'nova-compute-kvm' do
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
