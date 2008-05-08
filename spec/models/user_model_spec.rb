require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "user_model_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe UserModel do
  include UserModelSpecHelper
  
  before(:each) do
    UserModel.clear_database_table
  end

  it "should have a login field" do
    user_model = UserModel.new
    user_model.should respond_to(:login)
    user_model.valid?
    user_model.errors.on(:login).should_not be_nil
  end
  
  it "should fail login if there are less than 3 chars" do
    user_model = UserModel.new
    user_model.login = "AB"
    user_model.valid?
    user_model.errors.on(:login).should_not be_nil
  end
  
  it "should not fail login with between 3 and 40 chars" do
    user_model = UserModel.new
    [3,40].each do |num|
      user_model.login = "a" * num
      user_model.valid?
      user_model.errors.on(:login).should be_nil
    end
  end
  
  it "should fail login with over 90 chars" do
    user_model = UserModel.new
    user_model.login = "A" * 41
    user_model.valid?
    user_model.errors.on(:login).should_not be_nil    
  end
  
  it "should make a valid user_model" do
    user_model = UserModel.new(valid_user_model_hash)
    user_model.save
    user_model.errors.should be_empty
    
  end
  
  it "should make sure login is unique" do
    user_model = UserModel.new( valid_user_model_hash.with(:login => "Daniel") )
    user_model2 = UserModel.new( valid_user_model_hash.with(:login => "Daniel"))
    user_model.save.should be_true
    user_model.login = "Daniel"
    user_model2.save.should be_false
    user_model2.errors.on(:login).should_not be_nil
  end
  
  it "should make sure login is unique regardless of case" do
    UserModel.find_with_conditions(:login => "Daniel").should be_nil
    user_model = UserModel.new( valid_user_model_hash.with(:login => "Daniel") )
    user_model2 = UserModel.new( valid_user_model_hash.with(:login => "daniel"))
    user_model.save.should be_true
    user_model.login = "Daniel"
    user_model2.save.should be_false
    user_model2.errors.on(:login).should_not be_nil
  end
  
  it "should downcase logins" do
    user_model = UserModel.new( valid_user_model_hash.with(:login => "DaNieL"))
    user_model.login.should == "daniel"    
  end  
  
  it "should authenticate a user_model using a class method" do
    user_model = UserModel.new(valid_user_model_hash)
    user_model.save
    UserModel.authenticate(valid_user_model_hash[:login], valid_user_model_hash[:password]).should_not be_nil
  end
  
  it "should not authenticate a user_model using the wrong password" do
    user_model = UserModel.new(valid_user_model_hash)  
    user_model.save
    UserModel.authenticate(valid_user_model_hash[:login], "not_the_password").should be_nil
  end
  
  it "should not authenticate a user_model using the wrong login" do
    user_model = UserModel.create(valid_user_model_hash)  
    UserModel.authenticate("not_the_login", valid_user_model_hash[:password]).should be_nil
  end
  
  it "should not authenticate a user_model that does not exist" do
    UserModel.authenticate("i_dont_exist", "password").should be_nil
  end
  
  
end

describe UserModel, "the password fields for UserModel" do
  include UserModelSpecHelper
  
  before(:each) do
    UserModel.clear_database_table
    @user_model = UserModel.new( valid_user_model_hash )
  end
  
  it "should respond to password" do
    @user_model.should respond_to(:password)    
  end
  
  it "should respond to password_confirmation" do
    @user_model.should respond_to(:password_confirmation)
  end
  
  it "should have a protected password_required method" do
    @user_model.protected_methods.should include("password_required?")
  end
  
  it "should respond to crypted_password" do
    @user_model.should respond_to(:crypted_password)    
  end
  
  it "should require password if password is required" do
    user_model = UserModel.new( valid_user_model_hash.without(:password))
    user_model.stub!(:password_required?).and_return(true)
    user_model.valid?
    user_model.errors.on(:password).should_not be_nil
    user_model.errors.on(:password).should_not be_empty
  end
  
  it "should set the salt" do
    user_model = UserModel.new(valid_user_model_hash)
    user_model.salt.should be_nil
    user_model.send(:encrypt_password)
    user_model.salt.should_not be_nil    
  end
  
  it "should require the password on create" do
    user_model = UserModel.new(valid_user_model_hash.without(:password))
    user_model.save
    user_model.errors.on(:password).should_not be_nil
    user_model.errors.on(:password).should_not be_empty
  end  
  
  it "should require password_confirmation if the password_required?" do
    user_model = UserModel.new(valid_user_model_hash.without(:password_confirmation))
    user_model.save
    (user_model.errors.on(:password) || user_model.errors.on(:password_confirmation)).should_not be_nil
  end
  
  it "should fail when password is outside 4 and 40 chars" do
    [3,41].each do |num|
      user_model = UserModel.new(valid_user_model_hash.with(:password => ("a" * num)))
      user_model.valid?
      user_model.errors.on(:password).should_not be_nil
    end
  end
  
  it "should pass when password is within 4 and 40 chars" do
    [4,30,40].each do |num|
      user_model = UserModel.new(valid_user_model_hash.with(:password => ("a" * num), :password_confirmation => ("a" * num)))
      user_model.valid?
      user_model.errors.on(:password).should be_nil
    end    
  end
  
  it "should autenticate against a password" do
    user_model = UserModel.new(valid_user_model_hash)
    user_model.save    
    user_model.should be_authenticated(valid_user_model_hash[:password])
  end
  
  it "should not require a password when saving an existing user_model" do
    user_model = UserModel.create(valid_user_model_hash)
    user_model = UserModel.find_with_conditions(:login => valid_user_model_hash[:login])
    user_model.password.should be_nil
    user_model.password_confirmation.should be_nil
    user_model.login = "some_different_login_to_allow_saving"
    (user_model.save).should be_true
  end
  
end


describe UserModel, "remember_me" do
  include UserModelSpecHelper
  
  predicate_matchers[:remember_token] = :remember_token?
  
  before do
    UserModel.clear_database_table
    @user_model = UserModel.new(valid_user_model_hash)
  end
  
  it "should have a remember_token_expires_at attribute" do
    @user_model.attributes.keys.any?{|a| a.to_s == "remember_token_expires_at"}.should_not be_nil
  end  
  
  it "should respond to remember_token?" do
    @user_model.should respond_to(:remember_token?)
  end
  
  it "should return true if remember_token_expires_at is set and is in the future" do
    @user_model.remember_token_expires_at = DateTime.now + 3600
    @user_model.should remember_token    
  end
  
  it "should set remember_token_expires_at to a specific date" do
    time = Time.mktime(2009,12,25)
    @user_model.remember_me_until(time)
    @user_model.remember_token_expires_at.should == time    
  end
  
  it "should set the remember_me token when remembering" do
    time = Time.mktime(2009,12,25)
    @user_model.remember_me_until(time)
    @user_model.remember_token.should_not be_nil
    @user_model.save
    UserModel.find_with_conditions(:login => valid_user_model_hash[:login]).remember_token.should_not be_nil
  end
  
  it "should remember me for" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    today = Time.now
    remember_until = today + (2* Merb::Const::WEEK)
    @user_model.remember_me_for( Merb::Const::WEEK * 2)
    @user_model.remember_token_expires_at.should == (remember_until)
  end
  
  it "should remember_me for two weeks" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    @user_model.remember_me
    @user_model.remember_token_expires_at.should == (Time.now + (2 * Merb::Const::WEEK ))
  end
  
  it "should forget me" do
    @user_model.remember_me
    @user_model.save
    @user_model.forget_me
    @user_model.remember_token.should be_nil
    @user_model.remember_token_expires_at.should be_nil    
  end
  
  it "should persist the forget me to the database" do
    @user_model.remember_me
    @user_model.save
    
    @user_model = UserModel.find_with_conditions(:login => valid_user_model_hash[:login])
    @user_model.remember_token.should_not be_nil
    
    @user_model.forget_me

    @user_model = UserModel.find_with_conditions(:login => valid_user_model_hash[:login])
    @user_model.remember_token.should be_nil
    @user_model.remember_token_expires_at.should be_nil
  end
  
end