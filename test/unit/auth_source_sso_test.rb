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
      setup do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :status => ["200", "Success"])
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/present", :body => '', :status => ["204", "No Content"])
      end

      context "with on the fly register enabled" do
        setup do
          @auth_source.update_attribute(:onthefly_register, true)
        end

        should "return the user account from the server" do
          FakeWeb.register_uri(:post, "http://sso.example.com/accounts", :body => new_user_response, :status => ["201", "Created"])
          
          user = @auth_source.authenticate('user','password')

          assert user.is_a?(Hash), "User hash not returned"
          assert_equal "user", user['login']
          assert_equal "user", user['firstname']
          assert_equal "user", user['lastname']
          assert_equal "no-email-14@example.com", user['mail']
          assert_equal "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8", user['hash_password']
        end
      end
    end

    context "with on the fly register disabled" do
      should "return nil" do
        @auth_source.update_attribute(:onthefly_register, false)
        
        assert_equal nil, @auth_source.authenticate('user','password')
      end
    end
      
    context "with an existing user" do
      setup do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :status => ["200", "Success"])
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/present", :body => '', :status => ["200", "Success"])
      end
      
      context "with a successful authentication" do
        should "return the user account from the server" do
          FakeWeb.register_uri(:post, "http://sso.example.com/login", :body => valid_user_response)

          user = @auth_source.authenticate('user','password')

          assert user.is_a?(Hash), "User hash not returned"
          assert_equal "user", user['login']
          assert_equal "John", user['firstname']
          assert_equal "Doe", user['lastname']
          assert_equal "test@example.com", user['mail']
          assert_equal "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8", user['hash_password']
        end
      end

      context "with a failed authentication" do
        should "return nil" do
          FakeWeb.register_uri(:post, "http://sso.example.com/login", :body => '', :status => ["401", "Unauthorized"])

          assert_equal nil, @auth_source.authenticate('user', 'badpassword')
        end
      end
    end
  end
end
