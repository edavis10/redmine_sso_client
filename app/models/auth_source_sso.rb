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
      return login_to_sso_server(login, password)
    else
      return create_user_on_sso_server(login, password) if onthefly_register?
    end
  end

  def update_external(user)
    if user.changes.keys.include?('login')
      sso_account = user.changes['login'].first # use old value
    else
      sso_account = user.login
    end

    if connect_to_sso_server && user_present_on_sso_server(sso_account)
      return update_account_on_sso_server(sso_account, user.hashed_password, user.attributes.symbolize_keys)
    end

  end
  
end
