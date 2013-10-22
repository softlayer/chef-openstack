actions :setup_softlayer_networks, :softlayer_l3_config

attribute :env, :kind_of => Hash, :default => nil
attribute :private_cidr, :kind_of => String, :default => nil
attribute :public_cidr, :kind_of => String, :default => nil
