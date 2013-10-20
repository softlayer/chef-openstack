bash 'Clean libvirt networks' do
  user 'root'
  code <<-EOH
  virsh net-destroy default
  virsh net-undefine default
  EOH
  action :nothing
end

package 'libvirt-bin' do
  action :install
  notifies :run, resources(:bash => 'Clean libvirt networks'), :immediately
end

package 'pm-utils' do
  action :install
end

service 'libvirt-bin' do
  action :nothing
end

template '/etc/libvirt/qemu.conf' do
  source 'libvirt/qemu.conf'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'libvirt-bin')
end


template '/etc/init/libvirt-bin.conf' do
  source 'libvirt/libvirt-bin.conf'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'libvirt-bin')
end

template '/etc/default/libvirt-bin' do
  source 'libvirt/libvirt-bin'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'libvirt-bin')
end


template '/etc/libvirt/libvirtd.conf' do
  source 'libvirt/libvirtd.conf'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'libvirt-bin'), :immediately
end
