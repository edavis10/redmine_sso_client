class AuthSourceSso < AuthSource
  unloadable

  def auth_method_name
    "SSO"
  end

  def authenticate(login, password)
    return nil if login.blank? || password.blank?
    return nil unless connect

    if user_present(login)
      return user_login(login, password)
    else

    end
  end

  private

  def connect
    begin
      RestClient.get(self.host)
    rescue => e
      nil
    end
  end

  def user_present(login)
    RestClient.get(self.host + '/accounts/present', :login => login) {|response|
      case response.code
      when 200
        return true
      else
        return false
      end

    }
  end

  def user_login(login, password)
    RestClient.post(self.host + '/login', :login => login, :params => password) {|response|
      case response.code
      when 200
        raw_hash = Hash.from_xml(response)
        return raw_hash['user']
      else
        return nil
      end

    }

  end
end
