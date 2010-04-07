require File.dirname(__FILE__) + '/../test_helper'

class AuthSourceSsoTest < ActiveSupport::TestCase
  include FakeWebResponses

  def setup
    FakeWeb.clean_registry
  end
  
  should "be a subclass of AuthSource" do
    assert_equal AuthSource, AuthSourceSso.superclass
  end

  context "#authenticate" do
    setup do
      @auth_source = AuthSourceSso.new(:name => 'SSO Test', :host => 'http://sso.example.com')
    end
    
    should "return nil on a blank username" do
      assert_equal nil, @auth_source.authenticate(nil, 'password')
    end

    should "return nil on a blank password" do
      assert_equal nil, @auth_source.authenticate('user', nil)
    end

    context "with a failing server connection" do
      setup do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :body => "Not found", :status => ["404", "Not Found"])
      end
      
      should "return nil" do
        assert_equal nil, @auth_source.authenticate('user','password')
      end
    end

    context "with a new user" do
      should "create a new user on the server"
      should "return the user account from the server"
    end

    context "with an existing user" do
      should "return the user account from the server" do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :status => ["200", "Success"])
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/present", :body => '', :status => ["200", "Success"])
        FakeWeb.register_uri(:post, "http://sso.example.com/login", :body => valid_user_login)

        user = @auth_source.authenticate('user','password')

        assert user.is_a?(Hash), "User hash not returned"
        assert_equal "user", user['login']
        assert_equal "John", user['firstname']
        assert_equal "Doe", user['lastname']
        assert_equal "test@example.com", user['mail']
      end
    end
  end
end
