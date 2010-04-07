config.gem 'rest-client', :lib => 'rest_client'

require 'redmine'

Redmine::Plugin.register :redmine_sso_client do
  name 'Redmine SSO Client'
  author 'Eric Davis'
  description 'SSO Client implements a basic Single Sign On system for Redmine using the Redmine SSO Server (http://github.com/edavis10/redmine_sso_server)'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-sso'
  author_url 'http://www.littlestreamsoftware.com'

  version '0.1.0'

  requires_redmine :version_or_higher => '0.9.0'
  
  menu :admin_menu, :auth_source_sso, { :controller => 'sso_auth_sources', :action => 'index'}, :caption => :label_auth_source_sso
end
