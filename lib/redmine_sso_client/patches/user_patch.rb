module RedmineSsoClient
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable
          include InstanceMethods
          before_save :update_sso_server
        end
      end

      module InstanceMethods
        def update_sso_server
          if auth_source && auth_source.is_a?(AuthSourceSso) &&
              (changed != ['auth_source_id'] && changed != ['last_login_on'])
            auth_source.update_external(self)
          end
        end
      end
      
    end
  end
end
