require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "user_model_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe UserModels do
  
  include UserModelSpecHelper
  
  before(:each) do
    UserModel.clear_database_table
  end
  
  it 'allows signup' do
     lambda do
       controller = create_user_model
       controller.should redirect      
     end.should change(UserModel, :count).by(1)
   end

   it 'requires login on signup' do
     lambda do
       controller = create_user_model(:login => nil)
       controller.assigns(:user_model).errors.on(:login).should_not be_nil
       controller.should respond_successfully
     end.should_not change(UserModel, :count)
   end
    
   it 'requires password on signup' do
     lambda do
       controller = create_user_model(:password => nil)
       controller.assigns(:user_model).errors.on(:password).should_not be_nil
       controller.should respond_successfully
     end.should_not change(UserModel, :count)
   end
     
   it 'requires password confirmation on signup' do
     lambda do
       controller = create_user_model(:password_confirmation => nil)
       controller.assigns(:user_model).errors.on(:password_confirmation).should_not be_nil
       controller.should respond_successfully
     end.should_not change(UserModel, :count)
   end
   
   it 'requires email on signup' do
     lambda do
       controller = create_user_model(:email => nil)
       controller.assigns(:user_model).errors.on(:email).should_not be_nil
       controller.should respond_successfully
     end.should_not change(UserModel, :count)
   end
   
     
   def create_user_model(options = {})
     post "/user_models", :user_model => valid_user_model_hash.merge(options)
   end
end