include_recipe 'chef-openstack::common'

packages = %w[cinder-api
              cinder-scheduler
              cinder-volume
              python-mysqldb
              python-cinderclient
              sysfsutils
              gdisk
              linux-headers-generic]


packages.each do |pkg|
  package pkg do
    action :install
  end
end

%W[tgt open-iscsi].each do |srv|
  service srv do
     supports :status => true, :restart => true, :reload => true
     action :nothing
   end
end

%W[cinder-api cinder-scheduler cinder-volume].each do |srv|
  service srv do
    provider Chef::Provider::Service::Upstart
     supports :status => true, :restart => true, :reload => true
     action :nothing
   end
end

execute 'synchronize cinder database' do
  command 'cinder-manage db sync'
  action :nothing
end

package 'open-iscsi' do
  action :install
  notifies :restart, resources(:service => 'open-iscsi'), :immediately
end

package 'tgt' do
  action :install
  notifies :restart, resources(:service => 'tgt'), :immediately
end

template '/etc/cinder/api-paste.ini' do
  source 'cinder/api-paste.ini.erb'
  owner 'cinder'
  group 'cinder'
  mode '0644'
  notifies :run, resources(:execute => 'synchronize cinder database')
  notifies :restart, resources(:service => 'cinder-api')
  notifies :restart, resources(:service => 'cinder-volume')
  notifies :restart, resources(:service => 'cinder-scheduler')
end

template '/etc/cinder/cinder.conf' do
  source 'cinder/cinder.conf.erb'
  owner 'cinder'
  group 'cinder'
  mode '0644'
  notifies :run, resources(:execute => 'synchronize cinder database'), :immediately
  notifies :restart, resources(:service => 'cinder-api'), :immediately
  notifies :restart, resources(:service => 'cinder-volume'), :immediately
  notifies :restart, resources(:service => 'cinder-scheduler'), :immediately
end

unless File.exists?(node['cinder']['config']['lvm_disk'])
  raise "Can't find disk for cinder volume: #{node['cinder']['config']['lvm_disk']}"
end


# This code will wipe your cinder volume. Don't change your volume name once
# you have provisioned Cinder. You have been warned!
bash "Create #{node['cinder']['config']['volume_group']} lvm partition" do
  user 'root'
  not_if "vgdisplay | grep #{node['cinder']['config']['volume_group']}"

  code <<-EOH
    sgdisk --zap-all #{node['cinder']['config']['lvm_disk']}
    sgdisk --largest-new 1 #{node['cinder']['config']['lvm_disk']}
    sgdisk --typecode 1:8e00 #{node['cinder']['config']['lvm_disk']}

    ## Set up LVM for Cinder
    pvcreate #{node['cinder']['config']['lvm_disk']} -ff -y
    vgcreate #{node['cinder']['config']['volume_group']} \
             #{node['cinder']['config']['lvm_disk']}
    vgchange -ay #{node['cinder']['config']['volume_group']}
    vgs
  EOH
end
