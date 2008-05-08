require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
class UserModels < Application
  provides :xml
  
  skip_before :login_required
  
  def new
    only_provides :html
    @user_model = UserModel.new(params[:user_model] || {})
    display @user_model
  end
  
  def create
    cookies.delete :auth_token
    
    @user_model = UserModel.new(params[:user_model])
    if @user_model.save
      redirect_back_or_default('/')
    else
      render :new
    end
  end
  
end