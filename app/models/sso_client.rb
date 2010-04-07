module SsoClient
  def connect_to_sso_server
    begin
      RestClient.get(self.host)
    rescue => e
      nil
    end
  end

  def user_present_on_sso_server(login)
    RestClient.get(self.host + '/accounts/present', :login => login) {|response|
      case response.code
      when 200
        return true
      else
        return false
      end

    }
  end

  def login_to_sso_server(login, password)
    RestClient.post(self.host + '/login', :login => login, :password => password) {|response|
      case response.code
      when 200
        raw_hash = Hash.from_xml(response)
        return raw_hash['user']
      else
        return nil
      end

    }

  end

  def create_user_on_sso_server(login, password)
    RestClient.post(self.host + '/accounts', :user => {:login => login, :password => password}) {|response|

      case response.code
      when 200, 201 # Created
        raw_hash = Hash.from_xml(response)
        return raw_hash['user']
      else
        return nil
      end
    }
  end
end
