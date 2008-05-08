# Put the correct routes in place
module AuthenticatedSystem
  def self.add_routes
    Merb::BootLoader.after_app_loads do
      Merb::Router.prepend do |r|
        r.match("/login").to(:controller => "SessionController", :action => "create").name(:login)
        r.match("/logout").to(:controller => "SessionController", :action => "destroy").name(:logout)
        r.resources :user_models
        r.resources :session_controller
      end
    end
  end
end