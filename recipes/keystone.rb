packages = %w[keystone
              python-keystone
              python-keystoneclient
              python-mysqldb
              memcached
              python-memcache]


packages.each do |pkg|
  package pkg do
    action :install
  end
end

service 'keystone' do
  provider Chef::Provider::Service::Upstart
  action :nothing
end

execute 'keystone-manage db_sync' do
  user 'keystone'
  group 'keystone'
  command 'keystone-manage db_sync'
  action :nothing
end

directory '/etc/keystone' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

template '/etc/memcached.conf' do
  source 'memcached/memcached.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
end

template '/etc/keystone/keystone-paste.ini' do
  source 'keystone/keystone-paste.ini.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'keystone')
end

template '/etc/keystone/keystone.conf' do
  source 'keystone/keystone.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'keystone'), :immediately
  notifies :run, resources(:execute => 'keystone-manage db_sync'),
           :immediately
end

template '/root/.openrc' do
  source 'keystone/openrc.erb'
  owner 'root'
  group 'root'
  mode '0600'
end


# =================================================
# BEGIN Keystone HTTP setup
if node['keystone']['apache_frontend']
  service 'keystone' do
    provider Chef::Provider::Service::Upstart
    action [:disable, :stop]
  end

  %w[apache2 libapache2-mod-wsgi].each do |pkg|
    package pkg do
      action :install
    end
  end

  service 'apache2' do
    supports :status => true, :restart => true, :reload => true
    action :nothing
  end

  directory '/usr/share/keystone/wsgi' do
    owner 'root'
    group 'root'
    mode 00755
    recursive true
    action :create
    notifies :stop, "service[keystone]"
    notifies :restart, "service[apache2]"
  end

  template '/usr/share/keystone/wsgi/main' do
    source 'keystone/keystone.py'
    owner 'root'
    group 'root'
    mode 00644
    notifies :stop, "service[keystone]"
    notifies :restart, "service[apache2]"
  end

  template '/usr/share/keystone/wsgi/admin' do
    source 'keystone/keystone.py'
    owner 'root'
    group 'root'
    mode 00644
    notifies :stop, "service[keystone]"
    notifies :restart, "service[apache2]"
  end

  directory '/var/log/keystone' do
    group 'www-data'
    mode '0777'
    action :create
  end

  file '/var/log/keystone/keystone.log' do
    group 'www-data'
    mode '0666'
    action :create
  end

  # Ubuntu
  directory '/etc/apache2/conf.d/' do
    owner 'root'
    group 'root'
    mode 00755
    recursive true
    action :create
  end

  template '/etc/apache2/conf.d/wsgi-keystone.conf' do
    source 'keystone/wsgi-keystone.conf'
    owner 'root'
    group 'root'
    mode 00644
    notifies :stop, resources(:service => 'keystone'), :immediately
    notifies :restart, resources(:service => 'apache2'), :immediately
  end
end

# END Keystone HTTP setup
# =================================================


include_recipe 'chef-openstack::keystone-setup'
