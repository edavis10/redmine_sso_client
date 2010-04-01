require File.dirname(__FILE__) + '/../test_helper'

class AuthSourceSsoTest < ActiveSupport::TestCase
  should "be a subclass of AuthSource" do
    assert_equal AuthSource, AuthSourceSso.superclass
  end
end
