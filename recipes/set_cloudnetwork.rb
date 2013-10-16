include_recipe "partial_search"


#This code iterates through node["admin"]["cloud_network"]["roles"] to find network information about 
#each role.   Then, populates the public and private IP info for further use throughout the cookbook.
#Chef environments are used to isolate different installations from each other.
#=========================================================================
puts "Current environment is: \"#{node.chef_environment}\""
if node.chef_environment.index("default")
	raise "Not in a working environment"
end

#If the mysql-all recipe is used, we need to set the mysql hash values to "openstack-mysql-all"
use_mysql_all = search(:node, "role:openstack-mysql-all AND chef_environment:#{node.chef_environment}")

unless use_mysql_all.empty?
	node["admin"]["cloud_network"]["roles"].each_pair do |var, role|
		if /mysql/.match(var)
			node.default["admin"]["cloud_network"]["roles"][var] = "openstack-mysql-all"
		end
	end
end

node["admin"]["cloud_network"]["roles"].each_pair do |var, role|

	nodes = partial_search(:node, "role:#{role} AND chef_environment:#{node.chef_environment}", 
		:keys => {
					'network_info' => ['network']
				})

	current_node = nil
	current_node = nodes[rand(nodes.length)]
	if current_node == nil
		raise "Cannot find role: #{role} in environment #{node.chef_environment}\n\nYou may need to wait a few seconds after bootstrapping or check that all roles have been assigned."
	end
	is_bonded = "False" 
	current_node['br-ex_ip'] = nil

	current_node['network_info']['interfaces'].each do |iface, addrs|
	  
	  is_bonded = "True" if iface.start_with?('bond')
	 
	  addrs['addresses'].each do |ip, params|
		current_node["#{iface}_ip"] = ip if params['family'].eql?('inet')
	  end
	 
	end


	if current_node['br-priv_ip'].nil?
		node.default[var][:private_ip] = current_node["#{node["network"]["private_interface"]}_ip"]
	else
		node.default[var][:private_ip] = current_node['br-priv_ip']
	end
	if current_node['br-ex_ip'].nil?
		node.default[var][:public_ip] = current_node["#{node["network"]["public_interface"]}_ip"]
	else
		node.default[var][:public_ip] = current_node['br-ex_ip']
	end


end