# require  'lib/authenticated_system_controller'
require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
class SessionController < Application
  
  skip_before :login_required
  
  def new
    render
  end

  def create
    self.current_user_model = UserModel.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user_model.remember_me
        cookies[:auth_token] = { :value => self.current_user_model.remember_token , :expires => self.current_user_model.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      render :new
    end
  end

  def destroy
    self.current_user_model.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default('/')
  end
  
end