#This file is for Vagrant testing purposes only.  Several configuration decisions were made based on
#standing up the install in an isolated environment.   Do not follow these practices in production.
#Author:  Paul Sroufe <psroufe@softlayer.com>

sudo echo "192.168.50.4     openstack" >> /etc/hosts

wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.8-1.ubuntu.12.04_amd64.deb
sudo dpkg -i chef-server_11.0.8-1.ubuntu.12.04_amd64.deb
#sudo dpkg -i /vagrant/chef-server_11.0.8-1.ubuntu.12.04_amd64.deb
sudo chef-server-ctl reconfigure
sudo apt-get install git sshpass -y

#Not for production: Follow OpsCode guide for setting up knife.
sudo chmod 644 /etc/chef-server/*
sudo chmod 755 /etc/chef-server

mkdir /home/vagrant/.chef
cat >/home/vagrant/.chef/knife.rb <<EOF
log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '/etc/chef-server/admin.pem'
validation_client_name   'chef-validator'
validation_key           '/etc/chef-server/chef-validator.pem'
chef_server_url          'https://192.168.50.5'
syntax_check_cache_path  '/home/vagrant/.chef/syntax_check_cache'
cookbook_path            [ '/home/vagrant/chef-repo/cookbooks' ]
role_path                [ '/home/vagrant/chef-repo/cookbooks/grizzly/roles']
EOF

mkdir ~/.chef
cat >~/.chef/knife.rb <<EOF
log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '/etc/chef-server/admin.pem'
validation_client_name   'chef-validator'
validation_key           '/etc/chef-server/chef-validator.pem'
chef_server_url          'https://192.168.50.5'
syntax_check_cache_path  '/home/vagrant/.chef/syntax_check_cache'
cookbook_path            [ '/home/vagrant/chef-repo/cookbooks' ]
role_path                [ '/home/vagrant/chef-repo/cookbooks/grizzly/roles']
EOF

git clone git://github.com/opscode/chef-repo.git /home/vagrant
git clone https://github.com/opscode-cookbooks/mysql /home/vagrant/chef-repo/cookbooks/mysql
git clone https://github.com/opscode-cookbooks/partial_search /home/vagrant/chef-repo/cookbooks/partial_search
git clone https://github.com/opscode-cookbooks/ntp /home/vagrant/chef-repo/cookbooks/ntp
cd /home/vagrant/chef-repo/cookbooks/ntp
git checkout 1.3.2
cd ~
git clone https://github.com/opscode-cookbooks/build-essential /home/vagrant/chef-repo/cookbooks/build-essential
git clone https://github.com/opscode-cookbooks/openssl /home/vagrant/chef-repo/cookbooks/openssl
cp -r /vagrant/cookbooks/grizzly /home/vagrant/chef-repo/cookbooks/

/opt/chef-server/embedded/bin/knife cookbook upload --all
/opt/chef-server/embedded/bin/knife environment create OpenStack -d "OpenStack Test Suite"
/opt/chef-server/embedded/bin/knife role from file /home/vagrant/chef-repo/cookbooks/grizzly/roles/*

cat >~/openstack.json <<EOF
{
  "name": "OpenStack",
  "description": "OpenStack Test Suite",
  "cookbook_versions": {
  },
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "default_attributes": {
  },
  "override_attributes": {
   "network": {
      "public_interface": "eth0",
      "private_interface": "eth1"
   }
  }
}
EOF

/opt/chef-server/embedded/bin/knife environment from file ~/openstack.json

#Not for production: Use SSH keys
/opt/chef-server/embedded/bin/knife bootstrap 192.168.50.4 -x vagrant --sudo -P vagrant -E OpenStack

/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-mysql-all]'
/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-rabbitmq]'
/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-keystone]'
/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-controller]'
/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-cinder]'
/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-glance]'
/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-network]'
/opt/chef-server/embedded/bin/knife node run_list add openstack 'role[grizzly-compute]'

echo 'Waiting on Chef-Server configuration'
echo -ne '#####                     (25%)\r'
sleep 20
echo -ne '###########               (50%)\r'
sleep 20
echo -ne '###################       (75%)\r'
sleep 20
echo -ne '######################### (100%)\r'
echo -ne '\n\n'
echo 'Installing OpenStack, this can take a few minutes...'
sleep 2

#Not for production: Use SSH keys
sshpass -p 'vagrant' ssh openstack -l vagrant -o StrictHostKeyChecking=no "sudo chef-client"

echo 'Chef-Server is located at: https://127.0.0.1/  login: admin password: p@ssw0rd1'
echo 'Openstack is located at: http://127.0.0.1:7081 login: admin password: passwordsf'
