require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineSsoClient::Patches::UserPatchTest < ActiveSupport::TestCase
  include FakeWebResponses

  def setup
    FakeWeb.clean_registry
  end
  
  should "be included onto User" do
    assert User.included_modules.include?(RedmineSsoClient::Patches::UserPatch)
  end

  context "User#save" do
    setup do
      @user = User.generate_with_protected!(:login => 'sso')
    end

    context "without an AuthSourceSso" do
      should "save" do
        @user.login = 'newsso'

        assert @user.save

        assert_equal 'newsso', @user.reload.login
      end
    end

    context "with an AuthSourceSso" do
      setup do
        @auth_source = AuthSourceSso.generate!(:name => 'SSO Test', :host => 'http://sso.example.com')
        @user.auth_source = @auth_source
      end

      should "update the server's data before saving" do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :status => ["200", "Success"])
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/sso/present.xml", :body => '', :status => ["200", "Success"])
        FakeWeb.register_uri(:put, "http://sso.example.com/accounts/sso.xml", :body => '', :status => ["200", "Success"])

        @user.login = 'newsso'

        assert @user.save
        assert_equal 'newsso', @user.reload.login
      end
      
      should "return false if the server failed to update" do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :status => ["200", "Success"])
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/sso/present.xml", :body => '', :status => ["200", "Success"])
        FakeWeb.register_uri(:put, "http://sso.example.com/accounts/sso.xml", :body => '', :status => ["500", "Server Error"])

        @user.login = 'newsso'

        assert !@user.save
        assert_equal 'sso', @user.reload.login
      end

      should "allow changing passwords" do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :status => ["200", "Success"])
        FakeWeb.register_uri(:post, "http://sso.example.com/login.xml", :status => ["200", "Success"], :body => valid_user_response)
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/sso/present.xml", :body => '', :status => ["200", "Success"])
        FakeWeb.register_uri(:put, "http://sso.example.com/accounts/sso.xml", :body => '', :status => ["200", "Success"])

        @user.password = 'new-password'
        @user.password_confirmation = 'new-password'
        # TODO: need to trigger the cache for this to work.
        @user.check_password?('new-password')

        assert @user.save
        assert @user.reload.hashed_password.blank?, "Password was cached locally"

      end
    end
  end
  
  context "User#check_password?" do
    should 'cache the previous password into an instance variable if an auth source needs access to the cleartext password' do
      @user = User.generate_with_protected!(:login => 'sso')
      @auth_source = AuthSourceSso.generate!(:name => 'SSO Test', :host => 'http://sso.example.com')
      @user.auth_source = @auth_source
      assert_equal nil, @user.instance_variable_get('@previous_password')

      @user.check_password?('a-password')
      assert_equal 'a-password', @user.instance_variable_get('@previous_password')
    end
  end
end
