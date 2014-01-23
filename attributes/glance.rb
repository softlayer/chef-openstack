default['glance']['db']['name'] = 'glance'
default['glance']['db']['username'] = 'glance'
default['glance']['db']['password'] = 'gl4nc3'

default['glance']['service_tenant_name'] = 'service'
default['glance']['service_user'] = 'glance'

# Glance API
default['glance']['config']['debug'] = 'false'
default['glance']['config']['verbose'] = 'false'
default['glance']['config']['bind_host']['api'] = '0.0.0.0'
default['glance']['config']['bind_port']['api'] = '9292'
default['glance']['config']['log_file']['api'] = '/var/log/glance/api.log'
default['glance']['config']['workers'] = '10'
default['glance']['config']['allow_anonymous_access'] = 'False'
default['glance']['config']['show_image_direct_url'] = 'True'
default['glance']['config']['notifier_strategy'] = 'noop'
default['glance']['config']['filesystem_store_datadir'] = '/var/lib/glance/images/'
default['glance']['config']['image_cache_dir'] = '/var/lib/glance/image-cache/'
default['glance']['config']['flavor'] = 'keystone'

# RabbitMQ config
default['glance']['config']['rabbit_port'] = '5672'
default['glance']['config']['rabbit_use_ssl'] = 'false'
default['glance']['config']['rabbit_userid'] = 'guest'
default['glance']['config']['rabbit_password'] = 'guest'
default['glance']['config']['rabbit_notification_exchange'] = 'glance'
default['glance']['config']['rabbit_notification_topic'] = 'notifications'
default['glance']['config']['rabbit_durable_queues'] = 'False'

# Glance Registry
default['glance']['config']['bind_host']['registry'] = '0.0.0.0'
default['glance']['config']['bind_port']['registry'] = '9191'
default['glance']['config']['log_file']['registry'] = '/var/log/glance/registry.log'

default['glance']['images'] = {
  'CirrOS 0.3.0 i386' => 'https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-i386-disk.img',
  'CirrOS 0.3.0 x86_64' => 'https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img',
  'Fedora 19 (Cloud) x86_64' => 'http://download.fedoraproject.org/pub/fedora/linux/releases/19/Images/x86_64/Fedora-x86_64-19-20130627-sda.qcow2',
  'Fedora 19 (Cloud) i386' => 'http://download.fedoraproject.org/pub/fedora/linux/releases/19/Images/i386/Fedora-i386-19-20130627-sda.qcow2',
  'Ubuntu 12.04 Server (Cloud) amd64' => 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img',
  'Ubuntu 12.04 Server (Cloud) i386' => 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-i386-disk1.img',
  'Ubuntu 12.10 Server (Cloud) amd64' => 'http://cloud-images.ubuntu.com/quantal/current/quantal-server-cloudimg-amd64-disk1.img',
  'Ubuntu 12.10 Server (Cloud) i386' => 'http://cloud-images.ubuntu.com/quantal/current/quantal-server-cloudimg-i386-disk1.img',
  'Ubuntu 13.04 Server (Cloud) amd64' => 'http://cloud-images.ubuntu.com/raring/current/raring-server-cloudimg-amd64-disk1.img',
  'Ubuntu 13.04 Server (Cloud) i386' => 'http://cloud-images.ubuntu.com/raring/current/raring-server-cloudimg-i386-disk1.img',
  'Ubuntu 13.10 Server (Cloud) amd64' => 'http://cloud-images.ubuntu.com/saucy/current/saucy-server-cloudimg-amd64-disk1.img',
  'Ubuntu 13.10 Server (Cloud) i386' => 'http://cloud-images.ubuntu.com/saucy/current/saucy-server-cloudimg-i386-disk1.img'
}
