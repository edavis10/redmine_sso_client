module RedmineSsoClient
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable
          include InstanceMethods
          before_save :update_sso_server

          alias_method_chain 'check_password?'.to_sym, :caching_previous_password

        end
      end

      module InstanceMethods
        def check_password_with_caching_previous_password?(clear_password)
          @previous_password = clear_password if auth_source_id
          check_password_without_caching_previous_password?(clear_password)
        end

        def update_sso_server
          if auth_source && auth_source.is_a?(AuthSourceSso) &&
              (changed != ['auth_source_id'] && changed != ['last_login_on'])
            # Need to send plaintext password attributes to the server
            # if they are set (e.g. during change password)
            non_attributes = {}
            non_attributes['previous_password'] = @previous_password if @previous_password
            non_attributes['password'] = self.password if self.password
            non_attributes['password_confirmation'] = self.password_confirmation if self.password_confirmation

            auth_source.update_external(self, non_attributes)
          end
        end

      end
      
    end
  end
end
