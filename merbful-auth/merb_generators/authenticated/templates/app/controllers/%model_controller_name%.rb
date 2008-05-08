require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
class <%= model_controller_class_name %> < Application
  provides :xml
  
  skip_before :login_required
  
  def new
    only_provides :html
    @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>] || {})
    display @<%= singular_name %>
  end
  
  def create
    cookies.delete :auth_token
    
    @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
    if @<%= singular_name %>.save
      redirect_back_or_default('/')
    else
      render :new
    end
  end
  
<% if include_activation -%>
  def activate
    self.current_<%= singular_name %> = <%= class_name %>.find_activated_authenticated_model(params[:activation_code])
    if logged_in? && !current_<%= singular_name %>.active?
      current_<%= singular_name %>.activate
    end
    redirect_back_or_default('/')
  end
<% end -%>
end