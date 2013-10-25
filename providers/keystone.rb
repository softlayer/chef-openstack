action :create_user do
	finduser = Mixlib::ShellOut.new("keystone", "user-get", new_resource.user,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	finduser.run_command

	if finduser.stderr.index("No user with a name")

		run = Mixlib::ShellOut.new("keystone", 
			"user-create", 
			"--name=#{new_resource.user}", 
			"--pass=#{new_resource.password}", 
			"--email=#{new_resource.email}",

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}
			)

		run.run_command
		run.error! #Tell chef user if something went wrong
		
		puts "\nUser \"#{new_resource.user}\" was created with ID \"#{run.stdout.match /[a-f0-9]{25,}/}\""
	else
		if user_id.size == 0
     		raise "ID could not be found.  Check Keystone and retry."
    	end
		puts "\nThe user \"#{new_resource.user}\" already exists with ID \"#{finduser.stdout.match /[a-f0-9]{25,}/}\""
	end

end



action :create_tenant do

	findtenant = Mixlib::ShellOut.new("keystone", "tenant-get", new_resource.tenant,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	findtenant.run_command
		
	if findtenant.stderr.index("No tenant with a name")

		run = Mixlib::ShellOut.new("keystone", 
			"tenant-create", 
			"--name=#{new_resource.tenant}", 

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}
			)

		run.run_command
		run.error! #Tell chef user if something went wrong
		
		puts "\nTenant #{new_resource.tenant} was created with ID \"#{run.stdout.match /[a-f0-9]{25,}/}\""
	else
		puts "\nThe tenant \"#{new_resource.tenant}\" already exists with ID \"#{findtenant.stdout.match /[a-f0-9]{25,}/}\""
	end
end

action :create_role do

	findrole = Mixlib::ShellOut.new("keystone", "role-get", new_resource.role,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	findrole.run_command

	if findrole.stderr.index("No role with a name")

		run = Mixlib::ShellOut.new("keystone", 
			"role-create", 
			"--name=#{new_resource.role}", 

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}
			)

		run.run_command
		run.error! #Tell chef user if something went wrong
		
		puts "\nRole #{new_resource.role} was created with ID \"#{run.stdout.match /[a-f0-9]{25,}/}\""
	else
		puts "\nThe role \"#{new_resource.role}\" already exists with ID \"#{findrole.stdout.match /[a-f0-9]{25,}/}\""
	end

end

action :user_role_add do
	user_id = nil
	tenant_id = nil
	role_id = nil

	finduser = Mixlib::ShellOut.new("keystone", "user-get", new_resource.user,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	finduser.run_command
		
	if finduser.stderr.index("No user with a name")
		puts "The user \"#{new_resource.user}\" does not exist!!!"
	else
		user_id = finduser.stdout.match /[a-f0-9]{25,}/
	end

	findtenant = Mixlib::ShellOut.new("keystone", "tenant-get", new_resource.tenant,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	findtenant.run_command
		
	if findtenant.stderr.index("No tenant with a name")
		puts "The tenant \"#{new_resource.tenant}\" does not exist!!!"
	else
		tenant_id = findtenant.stdout.match /[a-f0-9]{25,}/
	end


	findrole = Mixlib::ShellOut.new("keystone", "role-get", new_resource.role,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	findrole.run_command

	if findrole.stderr.index("No role with a name")
		puts "The role \"#{new_resource.role}\" does not exist!!!"
	else
		role_id = findrole.stdout.match /[a-f0-9]{25,}/
	end


	user_update = Mixlib::ShellOut.new("keystone", "user-role-add", 
									 "--user-id", user_id.to_s,
									 "--tenant-id", tenant_id.to_s,
									 "--role-id", role_id.to_s,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	user_update.run_command


	if user_update.stderr.index("already has")
		puts "\nThe user-role has already been created."
	else
		puts "\nThe \"#{new_resource.user}\", \"#{new_resource.tenant}\", \"#{new_resource.role}\" definition has been added."
	end


end



action :create_service do

	findservice = Mixlib::ShellOut.new("keystone", "service-get", new_resource.name,

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

		)

	findservice.run_command
	puts findservice.stderr
		
	if findservice.stderr.index("No service with a name")

		run = Mixlib::ShellOut.new("keystone", 
			"service-create", 
			"--name", new_resource.name,
			"--type", new_resource.service_type,
			"--description", new_resource.description, 

		:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
						'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}
			)

		run.run_command
		run.error! #Let chef user know something then wrong.
		
		puts "\nService #{new_resource.name} was created with ID \"#{run.stdout.match /[a-f0-9]{25,}/}\""
	else
		puts "\nThe service \"#{new_resource.name}\" already exists with ID \"#{findservice.stdout.match /[a-f0-9]{25,}/}\""
	end

end


action :create_endpoint do

	findservice = Mixlib::ShellOut.new("keystone", "service-get", new_resource.service_type,

	:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
					'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

	)

	findservice.run_command
		
	if findservice.stderr.index("No service with a name")
		puts "The service \"#{new_resource.service_type}\" doesn't exist.  ENDPOINT NOT CREATED"
	else


		findendpoint = Mixlib::ShellOut.new("keystone", "endpoint-list",

			:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
							'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

			)

		findendpoint.run_command
		key_service = findservice.stdout.match /[a-f0-9]{25,}/
		endpoint_found = false

		findendpoint.stdout.each_line do |line|
			if line.index(new_resource.internal_url) and line.index(key_service.to_s) and line.index(new_resource.region)
				endpoint_found = true
			end
		end

		if endpoint_found
			puts "\n\t\tThe endpoint for \"#{new_resource.service_type}\" already exists.  Doing nothing.\n\n"
		else
			createendpoint = Mixlib::ShellOut.new("keystone", "endpoint-create",
												"--region", new_resource.region,
												"--service_id", key_service.to_s,
												"--publicurl", new_resource.public_url,
												"--adminurl", new_resource.admin_url,
												"--internalurl", new_resource.internal_url,

			:environment => {'SERVICE_TOKEN' => new_resource.keystone_service_pass,
							'SERVICE_ENDPOINT' => 'http://localhost:35357/v2.0'}

			)

			createendpoint.run_command
			createendpoint.error!
			puts "\n\t\tEndpoint for \"#{new_resource.service_type}\" in region \"#{new_resource.region}\" has been created.\n\n"
		end

	end

end
