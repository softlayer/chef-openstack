id_regex = /[a-f0-9]{25,}/


action :create_user do
  shell = Mixlib::ShellOut.new('keystone', 'user-get',
                               new_resource.user,
                               :environment => new_resource.env)
  shell.run_command

  if shell.stderr.index('No user with a name')
    create = Mixlib::ShellOut.new('keystone', 'user-create',
                               "--name=#{new_resource.user}",
                               "--pass=#{new_resource.password}",
                               "--email=#{new_resource.email}",
                               :environment => new_resource.env)
    create.run_command
    create.error!  # Tell chef user if something went wrong

    user_id = create.stdout.match id_regex
    puts "\nUser #{new_resource.user} was created with ID #{user_id}"
  else
    user_id = shell.stdout.match id_regex
    puts "\nUser #{new_resource.user} already exists with ID #{user_id}"
  end
end



action :create_tenant do
  find = Mixlib::ShellOut.new('keystone', 'tenant-get',
                               new_resource.tenant,
                              :environment => new_resource.env)
  find.run_command

  if find.stderr.index('No tenant with a name')
    create = Mixlib::ShellOut.new('keystone', 'tenant-create',
                                  "--name=#{new_resource.tenant}",
                                  :environment => new_resource.env)
    create.run_command
    create.error!  # Tell chef user if something went wrong

    tenant_id = create.stdout.match id_regex
    puts "\nTenant #{new_resource.tenant} was created with ID #{tenant_id}"
  else
    tenant_id = find.stdout.match id_regex
    puts "\nTenant #{new_resource.tenant} already exists with ID #{tenant_id}"
  end
end



action :create_role do
  find = Mixlib::ShellOut.new('keystone', 'role-get',
                              new_resource.role,
                              :environment => new_resource.env)
  find.run_command

  if find.stderr.index('No role with a name')
    create = Mixlib::ShellOut.new('keystone', 'role-create',
                                  "--name=#{new_resource.role}",
                                  :environment => new_resource.env)
    create.run_command
    create.error!  # Tell chef user if something went wrong

    role_id = create.stdout.match id_regex
    puts "\nRole #{new_resource.role} was created with ID #{role_id}"
  else
    role_id = find.stdout.match id_regex
    puts "\nRole #{new_resource.role} already exists with ID #{role_id}"
  end
end



action :user_role_add do
  user_id = nil
  tenant_id = nil
  role_id = nil

  find = Mixlib::ShellOut.new('keystone', 'user-get',
                              new_resource.user,
                              :environment => new_resource.env)
  find.run_command

  if find.stderr.index('No user with a name')
    puts "The user #{new_resource.user} does not exist!"
  else
    user_id = find.stdout.match id_regex
  end


  find = Mixlib::ShellOut.new('keystone', 'tenant-get',
                              new_resource.tenant,
                              :environment => new_resource.env)
  find.run_command

  if find.stderr.index('No tenant with a name')
    puts "The tenant #{new_resource.tenant} does not exist!"
  else
    tenant_id = find.stdout.match id_regex
  end


  find = Mixlib::ShellOut.new('keystone', 'role-get',
                              new_resource.role,
                              :environment => new_resource.env)
  find.run_command

  if find.stderr.index('No role with a name')
    puts "The role #{new_resource.role} does not exist!"
  else
    role_id = find.stdout.match id_regex
  end

  update = Mixlib::ShellOut.new('keystone', 'user-role-add',
                                '--user-id', user_id.to_s,
                                '--tenant-id', tenant_id.to_s,
                                '--role-id', role_id.to_s,
                                :environment => new_resource.env)
  update.run_command

  if update.stderr.index('already has')
    puts "\nThat user-role has already been created."
  else
    puts "\nUser role #{new_resource.user}, #{new_resource.tenant}, " +
         "#{new_resource.role} has been added."
  end
end



action :create_service do
  find = Mixlib::ShellOut.new('keystone', 'service-get',
                              new_resource.name,
                              :environment => new_resource.env)
  find.run_command

  if find.stderr.index('No service with a name')
    create = Mixlib::ShellOut.new('keystone', 'service-create',
                                  '--name', new_resource.name,
                                  '--type', new_resource.service_type,
                                  '--description', new_resource.description,
                                  :environment => new_resource.env)
    create.run_command
    create.error! #Let chef user know something then wrong.

    service_id = create.stdout.match id_regex
    puts "\nService #{new_resource.name} was created with ID #{service_id}"
  else
    service_id = find.stdout.match id_regex
    puts "\nService #{new_resource.name} already exists with ID #{service_id}"
  end
end



action :create_endpoint do
  find = Mixlib::ShellOut.new('keystone', 'service-get',
                              new_resource.service_type,
                              :environment => new_resource.env)
  find.run_command

  if find.stderr.index('No service with a name')
    puts "The service #{new_resource.service_type} doesn't exist." +
         'ENDPOINT NOT CREATED!'
  else
    service_id = find.stdout.match id_regex
    endpoint_found = false

    find = Mixlib::ShellOut.new('keystone', 'endpoint-list',
                                :environment => new_resource.env)
    find.run_command

    find.stdout.each_line do |line|
      if line.index(new_resource.internal_url) \
         and line.index(service_id.to_s) \
         and line.index(new_resource.region)

        endpoint_found = true
      end
    end

    if endpoint_found
      puts "\nEndpoint for #{new_resource.service_type} already exists"
    else
      create = Mixlib::ShellOut.new('keystone', 'endpoint-create',
                                    '--region', new_resource.region,
                                    '--service_id', service_id.to_s,
                                    '--publicurl', new_resource.public_url,
                                    '--adminurl', new_resource.admin_url,
                                    '--internalurl', new_resource.internal_url,
                                    :environment => new_resource.env)
      create.run_command
      create.error!

      puts "\nEndpoint created for #{new_resource.service_type} " +
           "in region #{new_resource.region}"
    end
  end
end
