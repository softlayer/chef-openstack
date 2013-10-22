module Stack
  def self.keystone_admin_env(node)
    keystone_auth_url = "http://#{node[:keystone][:private_ip]}:" \
                        "#{node['keystone']['config']['public_port']}/v2.0"

    { "OS_USERNAME" => "admin",
      "OS_PASSWORD" => node[:admin][:password],
      "OS_TENANT_NAME" => "admin",
      "OS_AUTH_URL"  => keystone_auth_url }
  end

  def self.keystone_service_env(node)
    keystone_service_url = "http://#{node[:keystone][:private_ip]}:" \
                           "#{node['keystone']['config']['admin_port']}/v2.0"

    { 'SERVICE_TOKEN' => node[:admin][:password],
      'SERVICE_ENDPOINT' => keystone_service_url }
  end
end
