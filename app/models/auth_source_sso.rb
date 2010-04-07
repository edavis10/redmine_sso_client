class AuthSourceSso < AuthSource
  unloadable
  
  include SsoClient

  def auth_method_name
    "SSO"
  end

  def authenticate(login, password)
    return nil if login.blank? || password.blank?
    return nil unless connect

    if user_present(login)
      return user_login(login, password)
    else
      return create_stub_user(login, password) if onthefly_register?
    end
  end

end
