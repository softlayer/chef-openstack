package 'apparmor' do
  action :purge
end

include_recipe 'mysql::server'
