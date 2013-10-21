# The networking retrieval for public and private side data is based on
# SoftLayer's implementation of local and public interfaces as well as bonded
# interfaces. This will need to be tweaked to work with outside network
# implementations.

require 'ohai'

ohai_system = Ohai::System.new
ohai_system.all_plugins
ohai_system.seen_plugins       

if node['virtualization']['role'] == 'guest'
  node.default[:node_info][:is_vm] = 'True'
else
  node.default[:node_info][:is_vm] = 'False'
end

puts "VM Mode: #{node[:node_info][:is_vm]}"

network = ohai_system.network

node.default[:node_info][:is_bonded] = 'False' 
network['br-ex_ip'] = nil
network['br-priv_ip'] = nil

network['interfaces'].each do |iface, addrs|
 
  node.default[:node_info][:is_bonded] = 'True' if iface.start_with?('bond')

  # Applies to SoftLayer configuration
  if addrs.has_key?('routes')
    addrs['routes'].each do |route|
      network["#{iface}_via"] = route['via'] if route.has_key?('via') \
                                             and route['family'].eql?('inet')
      network["#{iface}_dest"] = route['destination'] \
                                 if route.has_key?('via') \
                                 and route['family'].eql?('inet')
    end
  end

  addrs['addresses'].each do |ip, params|
  network["#{iface}_ip"] = ip if params['family'].eql?('inet')
  network["#{iface}_iface"] = iface if params['family'].eql?('inet')
  network["#{iface}_subnet"] = params['netmask'] \
                               if params['family'].eql?('inet')
  network["#{iface}_cidr"] = params['prefixlen'] \
                             if params['family'].eql?('inet')
  end
 
end


priv_iface = node['network']['private_interface']
pub_iface = node['network']['public_interface']

if network['br-priv_ip'].nil?
  node.default[:node_info][:private_iface] = network["#{priv_iface}_iface"]
  node.default[:node_info][:private_ip] = network["#{priv_iface}_ip"]
  node.default[:node_info][:private_subnet] = network["#{priv_iface}_subnet"]
  node.default[:node_info][:private_cidr] = network["#{priv_iface}_cidr"]
  node.default[:node_info][:private_via] = network["#{priv_iface}_via"]
  node.default[:node_info][:private_dest] = network["#{priv_iface}_dest"]
else
  # Neutron information is dependent on pre-bridge info
  node.default[:node_info][:private_iface] = priv_iface
  node.default[:node_info][:private_ip] = network['br-priv_ip']
  node.default[:node_info][:private_subnet] = network['br-priv_subnet']
  node.default[:node_info][:private_cidr] = network['br-priv_cidr']
  node.default[:node_info][:private_via] = network['br-priv_via']
  node.default[:node_info][:private_dest] = network['br-priv_dest']
end

if network['br-ex_ip'].nil?
  node.default[:node_info][:public_iface] = network["#{pub_iface}_iface"]
  node.default[:node_info][:public_ip] = network["#{pub_iface}_ip"]
  node.default[:node_info][:public_subnet] = network["#{pub_iface}_subnet"]
  node.default[:node_info][:public_cidr] = network["#{pub_iface}_cidr"]
  node.default[:node_info][:public_via] = network["#{pub_iface}_via"]
  node.default[:node_info][:public_dest] = network["#{pub_iface}_dest"]
else
  # Neutron information is dependent on pre-bridge info
  node.default[:node_info][:public_iface] = pub_iface
  node.default[:node_info][:public_ip] = network['br-ex_ip']
  node.default[:node_info][:public_subnet] = network['br-ex_subnet']
  node.default[:node_info][:public_cidr] = network['br-ex_cidr']
  node.default[:node_info][:public_via] = network['br-ex_via']
  node.default[:node_info][:public_dest] = network['br-ex_dest']
end



node.default[:node_info][:default_gateway] = network['default_gateway']


# Debug networking output
template '/root/attributes.txt' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'attributes.txt.erb'
end
