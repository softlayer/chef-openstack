default['keystone']['debug'] = 'false'
default['keystone']['verbose'] = 'false'

default['keystone']['db']['name'] = 'keystone'
default['keystone']['db']['username'] = 'keystone'
default['keystone']['db']['password'] = 'k3yst0n3'

default['keystone']['service_tenant_name'] = 'service'
default['keystone']['service_user'] = 'keystone'

default['keystone']['apache_frontend'] = true
default['keystone']['config']['bind_host'] = '0.0.0.0'
default['keystone']['config']['public_port'] = '5000'
default['keystone']['config']['admin_port'] = '35357'
default['keystone']['config']['log_file'] = 'keystone.log'
default['keystone']['config']['log_dir'] = '/var/log/keystone'
default['keystone']['config']['token_format'] = 'UUID'  # or PKI

# Keystone backend drivers
default['keystone']['config']['driver']['identity'] = 'keystone.identity.backends.sql.Identity'
default['keystone']['config']['driver']['catalog'] = 'keystone.catalog.backends.sql.Catalog'
default['keystone']['config']['driver']['token'] = 'keystone.token.backends.memcache.Token'
default['keystone']['config']['driver']['policy'] = 'keystone.policy.backends.sql.Policy'
default['keystone']['config']['driver']['ec2'] = 'keystone.contrib.ec2.backends.sql.Ec2'
default['keystone']['config']['driver']['credential'] = 'keystone.credential.backends.sql.Credential'
default['keystone']['config']['driver']['trust'] = 'keystone.trust.backends.sql.Trust'

# Keystone Regions
default['keystone']['region_servers'] = nil
# {'region_name' => 'xx.xx.xx.xx', 'region_name_2' => 'xx.xx.xx.yy'}


# Keystone default accounts. These are only set once and an override is used
# to prevent further runs.
admin_pass = node[:admin][:password]

default['keystone']['default_accounts']['users'] = {
  'admin' => {'email' => 'root@localhost', 'password' => admin_pass },
  'demo' => {'email' => 'demo@localhost', 'password' => admin_pass },
  'nova' => {'email' => 'nova@localhost', 'password' => admin_pass },
  'glance' => {'email' => 'glance@localhost', 'password' => admin_pass },
  'neutron' => {'email' => 'neutron@localhost', 'password' => admin_pass },
  'reseller' => {'email' => 'reseller@localhost', 'password' => admin_pass },
  'cinder' => {'email' => 'cinder@localhost', 'password' => admin_pass }
}

default['keystone']['default_accounts']['tenants'] = ['admin', 'demo',
                                                       'service']

default['keystone']['default_accounts']['roles'] = ['admin', 'KeystoneAdmin',
                                                     'KeystoneServiceAdmin',
                                                     'Member', 'ResellerAdmin']

default['keystone']['default_accounts']['services'] = {
  'nova' => { 'type' => 'compute',
              'description' => 'OpenStack Compute Service' },

  'cinder' => { 'type' => 'volume',
                'description' => 'OpenStack Volume Service' },

  'glance' => { 'type' => 'image',
                'description' => 'OpenStack Image Service' },

  'keystone' => { 'type' => 'identity',
                  'description' => 'OpenStack Identity' },

  'ec2' => { 'type' => 'ec2',
             'description' => 'OpenStack EC2 service' },

  'neutron' => { 'type' => 'network',
                 'description' => 'OpenStack Networking service' }
}

default['keystone']['default_accounts']['user-roles'] = [
  { 'role' => 'admin', 'user' => 'admin', 'tenant' => 'admin' },
  { 'role' => 'admin', 'user' => 'admin', 'tenant' => 'demo' },
  { 'role' => 'admin', 'user' => 'nova', 'tenant' => 'service' },
  { 'role' => 'admin', 'user' => 'glance', 'tenant' => 'service' },
  { 'role' => 'admin', 'user' => 'neutron', 'tenant' => 'service' },
  { 'role' => 'admin', 'user' => 'cinder', 'tenant' => 'service' },
  { 'role' => 'KeystoneAdmin', 'user' => 'admin', 'tenant' => 'admin' },
  { 'role' => 'KeystoneServiceAdmin', 'user' => 'admin', 'tenant' => 'admin' },
  { 'role' => 'Member', 'user' => 'demo', 'tenant' => 'demo' },
  { 'role' => 'ResellerAdmin', 'user' => 'nova', 'tenant' => 'service' }
]
