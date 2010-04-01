class AuthSourceSso < AuthSource
  unloadable

  def auth_method_name
    "SSO"
  end
end
