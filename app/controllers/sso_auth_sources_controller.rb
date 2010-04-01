class SsoAuthSourcesController < AuthSourcesController
  unloadable

  protected
  
  def auth_source_class
    AuthSourceSso
  end

end
