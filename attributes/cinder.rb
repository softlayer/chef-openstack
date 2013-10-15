default["cinder"]["db"]["name"] = "cinder"
default["cinder"]["db"]["username"] = "cinder"
default["cinder"]["db"]["password"] = "c1nd3r"

default["cinder"]["service_tenant_name"] = "service"
default["cinder"]["service_user"] = "cinder"

default["cinder"]["config"]["rabbit_password"] = "guest"
default["cinder"]["config"]["auth_strategy"] = "keystone"
default["cinder"]["config"]["volume_group"] = "cinder-volumes"

if node["virtualization"]["role"] == "guest"
	default["cinder"]["config"]["lvm_disk"] = "/dev/xvdc"
else
	default["cinder"]["config"]["lvm_disk"] = "/dev/sdb"
end
