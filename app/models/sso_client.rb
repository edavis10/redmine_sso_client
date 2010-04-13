module SsoClient
  def connect_to_sso_server
    begin
      RestClient.get(self.host)
    rescue => e
      nil
    end
  end

  def user_present_on_sso_server(login)
    RestClient.get(self.host + "/accounts/#{login}/present.xml") {|response|
      case response.code
      when 200
        logger.debug "SsoClient: User #{login} found on SSO Server" if logger
        return true
      else
        logger.debug "SsoClient: User #{login} not found on SSO Server" if logger
        return false
      end

    }
  end

  def login_to_sso_server(login, password)
    RestClient.post(self.host + '/login.xml', :login => login, :password => password) {|response|
      case response.code
      when 200
        logger.debug "SsoClient: User #{login} logged into SSO Server" if logger
        raw_hash = Hash.from_xml(response)
        return raw_hash['user']
      else
        logger.debug "SsoClient: User #{login} failed login to SSO Server" if logger
        return nil
      end

    }

  end

  def create_user_on_sso_server(login, password)
    RestClient.post(self.host + '/accounts.xml', :user => {:login => login, :password => password}) {|response|

      case response.code
      when 200, 201 # Created
        logger.debug "SsoClient: User #{login} created on SSO Server" if logger
        raw_hash = Hash.from_xml(response)
        return raw_hash['user']
      else
        logger.debug "SsoClient: User #{login} failed creation on SSO Server" if logger
        return nil
      end
    }
  end

  def update_account_on_sso_server(login, password, attributes)
    # Extract out only the attributes the SSO Server uses
    sso_attributes = {}
    sso_attributes[:login] = attributes.delete(:login)
    sso_attributes[:firstname] = attributes.delete(:firstname)
    sso_attributes[:lastname] = attributes.delete(:lastname)
    sso_attributes[:mail] = attributes.delete(:mail)
    sso_attributes[:password] = attributes.delete(:password)
    sso_attributes[:password_confirmation] = sso_attributes[:password]

    RestClient.put(self.host + "/accounts/#{login}.xml",
                   :login => login,
                   :password => password,
                   :user => sso_attributes) {|response|

      case response.code
      when 200
        logger.debug "SsoClient: User #{login} updated on SSO Server" if logger
        return true
      else
        logger.debug "SsoClient: User #{login} failed update on SSO Server" if logger
        return false
      end
    }
  end
end
