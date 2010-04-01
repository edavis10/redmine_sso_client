require File.dirname(__FILE__) + '/../test_helper'
require 'sso_auth_sources_controller'

# Re-raise errors caught by the controller.
class SsoAuthSourcesController; def rescue_action(e) raise e end; end

class SsoAuthSourcesControllerTest < ActionController::TestCase

  def setup
    @controller = SsoAuthSourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  should "be based on the AuthSourcesController" do
    assert_equal AuthSourcesController, SsoAuthSourcesController.superclass
  end
end
