# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

require 'fakeweb'
FakeWeb.allow_net_connect = false


class ActiveSupport::TestCase
end

module FakeWebResponses
  def valid_user_response
    '<?xml version="1.0" encoding="UTF-8"?>
<user>
  <created-on type="datetime">2009-07-21T17:10:04-07:00</created-on>
  <firstname>John</firstname>
  <lastname>Doe</lastname>
  <login>user</login>
  <mail>test@example.com</mail>
</user>'
  end

  def new_user_response
    '<?xml version="1.0" encoding="UTF-8"?>
<user>
  <created-on type="datetime">2009-07-21T17:10:04-07:00</created-on>
  <firstname>user</firstname>
  <lastname>user</lastname>
  <login>user</login>
  <mail>no-email-14@example.com</mail>
</user>'
  end
  
end
