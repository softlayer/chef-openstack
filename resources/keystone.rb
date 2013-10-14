actions :create_user, :create_tenant, :create_role, :user_role_add, :create_endpoint, :create_service

attribute :password, :kind_of => String, :default => nil
attribute :email, :kind_of => String, :default => nil
attribute :tenant, :kind_of => String, :default => nil
attribute :user, :kind_of => String, :default => nil
attribute :role, :kind_of => String, :default => nil
attribute :keystone_service_pass, :kind_of => String, :default => nil
attribute :service_type, :kind_of => String, :default => nil
attribute :description, :kind_of => String, :default => nil
attribute :name, :kind_of => String, :default => nil
attribute :region, :kind_of => String, :default => nil
attribute :keystone_server , :kind_of => String, :default => nil
attribute :internal_url, :kind_of => String, :default => nil
attribute :admin_url, :kind_of => String, :default => nil
attribute :public_url, :kind_of => String, :default => nil