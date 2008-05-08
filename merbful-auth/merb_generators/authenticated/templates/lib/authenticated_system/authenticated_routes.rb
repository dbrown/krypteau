# Put the correct routes in place
module AuthenticatedSystem
  def self.add_routes
    Merb::BootLoader.after_app_loads do
      Merb::Router.prepend do |r|
        r.match("/login").to(:controller => "<%= controller_class_name %>", :action => "create").name(:login)
        r.match("/logout").to(:controller => "<%= controller_class_name %>", :action => "destroy").name(:logout)
<% if include_activation -%>
        r.match("/<%= plural_name %>/activate/:activation_code").to(:controller => "<%= model_controller_class_name %>", :action => "activate").name(:<%= singular_name %>_activation)
<% end -%>
        r.resources :<%= plural_name %>
        r.resources :<%= controller_singular_name %>
      end
    end
  end
end