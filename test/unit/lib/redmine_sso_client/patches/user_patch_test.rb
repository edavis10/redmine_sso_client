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
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/present", :body => '', :status => ["200", "Success"])
        FakeWeb.register_uri(:put, "http://sso.example.com/accounts/sso", :body => '', :status => ["200", "Success"])

        @user.login = 'newsso'

        assert @user.save
        assert_equal 'newsso', @user.reload.login
      end
      
      should "return false if the server failed to update" do
        FakeWeb.register_uri(:any, "http://sso.example.com/", :status => ["200", "Success"])
        FakeWeb.register_uri(:get, "http://sso.example.com/accounts/present", :body => '', :status => ["200", "Success"])
        FakeWeb.register_uri(:put, "http://sso.example.com/accounts/sso", :body => '', :status => ["500", "Server Error"])

        @user.login = 'newsso'

        assert !@user.save
        assert_equal 'sso', @user.reload.login
      end
    end
  end
  

end
