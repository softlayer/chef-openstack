cinder_volume_group = node['cinder']['config']['volume_group']


default['nova']['debug'] = 'false'
default['nova']['verbose'] = 'false'

default['nova']['db']['name'] = 'nova'
default['nova']['db']['username'] = 'nova'
default['nova']['db']['password'] = 'n0v4n0v4'

default['nova']['service_tenant_name'] = 'service'
default['nova']['service_user'] = 'nova'

default['nova']['config']['ec2_workers'] = 10
default['nova']['config']['osapi_compute_workers'] = 10
default['nova']['config']['metadata_workers'] = 10
default['nova']['config']['conductor_workers'] = 10
default['nova']['config']['cpu_allocation_ratio'] = 4.0
default['nova']['config']['ram_allocation_ratio'] = 1.5
default['nova']['config']['disk_allocation_ratio'] = 1.0
default['nova']['config']['cinder_volume_group'] = cinder_volume_group
default['nova']['config']['rabbit_password'] = 'guest'
default['nova']['config']['novnc_enable'] = 'true'
default['nova']['config']['root_helper'] = 'sudo'
default['nova']['config']['logdir'] = '/var/log/nova'
default['nova']['config']['force_config_drive'] = 'True'
default['nova']['config']['running_deleted_instance_action'] = 'reap'
