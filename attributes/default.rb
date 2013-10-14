#Default's for Chef Environment
default["admin"]["password"]="passwordsf"
default["admin"]["email"]="admin@cloud.com"
default["admin"]["debug"]="False"

#Use eth1 and eth0 if provisioning CCI's or custom hardware.  Softlayer's hardware servers use bond1 and bond0.
#default["network"]["public_interface"] = "bond1"
#default["network"]["private_interface"] = "bond0"
default["network"]["public_interface"] = "eth1"
default["network"]["private_interface"] = "eth0"


#Mysql cookbook overrides
override['mysql']['bind_address']="0.0.0.0"
override['mysql']['remove_test_database']=true
override['mysql']['remove_anonymous_users']=true
override['mysql']['tunable']['innodb_thread_concurrency'] = "0"
override['mysql']['tunable']['innodb_commit_concurrency'] = "0"
override['mysql']['tunable']['innodb_read_io_threads'] = "64"
override['mysql']['tunable']['innodb_write_io_threads'] = "64"

#NTP cookbook overrides
override['ntp']['servers']=["time.softlayer.com", "time.service.networklayer.com"]

#Cloud network setup
#"<variable name>" => "<Chef role name>"
#By default the mysql recipes are seperated, if the grizzly-mysql-all role is used set_cloudnetwork will set the correct recipe.
default["admin"]["cloud_network"]["roles"] = {

	"controller" => "grizzly-controller",
	"network" => "grizzly-network",
	"rabbitmq" => "grizzly-rabbitmq",
	"keystone" => "grizzly-keystone",
	"glance" => "grizzly-glance",
	"cinder" => "grizzly-cinder",
	"mysqlglance" => "grizzly-mysql-glance",
	"mysqlcinder" => "grizzly-mysql-cinder",
	"mysqlkeystone" => "grizzly-mysql-keystone",
	"mysqlnova" => "grizzly-mysql-nova",
	"mysqlquantum" => "grizzly-mysql-quantum"

}

