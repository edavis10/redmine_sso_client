class AuthSourceSso < AuthSource
  unloadable
  
  include SsoClient

  def auth_method_name
    "SSO"
  end

  def authenticate(login, password)
    return nil if login.blank? || password.blank?
    return nil unless connect_to_sso_server

    if user_present_on_sso_server(login)
      return format_user_hash_for_redmine_auth_source(login_to_sso_server(login, password))
    else
      logger.debug "AuthSourceSSO: User #{login} not found on SSO Server" if logger
      if onthefly_register?
        logger.debug "AuthSourceSSO: Attempting to create remote User #{login} on the fly" if logger
        return format_user_hash_for_redmine_auth_source(create_user_on_sso_server(login, password))
      end
    end
  end

  def update_external(user, non_attributes={})
    if user.changes.keys.include?('login')
      sso_account = user.changes['login'].first # use old value
    else
      sso_account = user.login
    end
    
    attributes = user.attributes.merge(non_attributes).symbolize_keys

    if connect_to_sso_server && user_present_on_sso_server(sso_account)
      return update_account_on_sso_server(sso_account,
                                          attributes[:previous_password] || user.hashed_password,
                                          attributes)
    end

  end

  def test_connection
    RestClient.get(self.host)
  end

  def self.allow_password_changes?
    true
  end

  private

  # Need to tidy up the data into the format that Redmine requires
  def format_user_hash_for_redmine_auth_source(user_hash)
    return nil unless user_hash
    
    [
     user_hash.
     except('created_at').
     except('updated_at').
     except('id').
     merge('auth_source_id' => self.id)
    ]
  end
end
