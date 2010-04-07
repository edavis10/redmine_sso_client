module SsoClient
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

  def create_stub_user(login, password)
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
