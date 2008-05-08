require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "user_model_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")
require 'cgi'

describe "SessionController Controller", "index action" do
  include UserModelSpecHelper
  
  before(:each) do
    UserModel.clear_database_table
    @quentin = UserModel.create(valid_user_model_hash.with(:login => "quentin", :password => "test", :password_confirmation => "test"))
    @controller = SessionController.new(fake_request)
  end
  
  it "should have a route to SessionController#new from '/login'" do
    request_to("/login") do |params|
      params[:controller].should == "SessionController"
      params[:action].should == "create"
    end   
  end
  
  it "should route to SessionController#create from '/login' via post" do
    request_to("/login", :post) do |params|
      params[:controller].should  == "SessionController"
      params[:action].should      == "create"
    end      
  end
  
  it "should have a named route :login" do
    @controller.url(:login).should == "/login"
  end
  
  it "should have route to SessionController#destroy from '/logout' via delete" do
    request_to("/logout", :delete) do |params|
      params[:controller].should == "SessionController"
      params[:action].should    == "destroy"
    end   
  end
  
  it "should route to SessionController#destroy from '/logout' via get" do
    request_to("/logout") do |params|
      params[:controller].should == "SessionController" 
      params[:action].should     == "destroy"
    end
  end

  it 'logins and redirects' do
    controller = post "/login", :login => 'quentin', :password => 'test'
    controller.session[:user_model].should_not be_nil
    controller.session[:user_model].should == @quentin.id
    controller.should redirect_to("/")
  end
   
  it 'fails login and does not redirect' do
    controller = post "/login", :login => 'quentin', :password => 'bad password'
    controller.session[:user_model].should be_nil
    controller.should be_successful
  end

  it 'logs out' do
    controller = get("/logout"){|controller| controller.stub!(:current_user_model).and_return(@quentin) }
    controller.session[:user_model].should be_nil
    controller.should redirect
  end

  it 'remembers me' do
    controller = post "/login", :login => 'quentin', :password => 'test', :remember_me => "1"
    controller.cookies["auth_token"].should_not be_nil
  end
 
  it 'does not remember me' do
    controller = post "/login", :login => 'quentin', :password => 'test', :remember_me => "0"
    controller.cookies["auth_token"].should be_nil
  end
  
  it 'deletes token on logout' do
    controller = get("/logout") {|request| request.stub!(:current_user_model).and_return(@quentin) }
    controller.cookies["auth_token"].should == nil
  end
  
  
  it 'logs in with cookie' do
    @quentin.remember_me
    controller = get "/login" do |c|
      c.request.env[Merb::Const::HTTP_COOKIE] = "auth_token=#{@quentin.remember_token}"
    end
    controller.should be_logged_in
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user_model)
    auth_token user_model.remember_token
  end
end