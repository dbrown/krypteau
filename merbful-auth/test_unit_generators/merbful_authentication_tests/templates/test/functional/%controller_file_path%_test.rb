require File.dirname(__FILE__) + '/../test_helper'
require (File.dirname(__FILE__) / '../authenticated_system_test_helper')
require (File.dirname(__FILE__) / ".." / "<%= singular_name %>_test_helper")
include <%= class_name %>TestHelper

# Re-raise errors caught by the controller.
class <%= controller_class_name %>; def rescue_action(e) raise e end; end

class <%= controller_class_name %>ControllerTest < Test::Unit::TestCase

  def setup
    <%= class_name %>.clear_database_table
    @controller = <%= controller_class_name %>.new(fake_request)
    @controller.setup_session
      
    @<%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash.with(:login => 'quentin', :password => 'test', :password_confirmation => 'test'))
    @<%= singular_name %>.save
<% if options[:include_activation] -%>
    @<%= singular_name %>.activate
<% end -%>
  end
  
  def test_helper_login_as_method
    login_as :quentin
    assert @controller.send(:logged_in?)
  end

  def test_should_login_and_redirect
    @controller.params.merge!(:login => 'quentin', :password => 'test')
    @controller._dispatch(:create)
    assert @controller.session[:<%= singular_name %>]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    @controller.params.merge!(:login => 'quentin', :password => 'bad password')
    @controller._dispatch(:create)
    assert_nil @controller.session[:<%= model_file_name %>]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    @controller._dispatch(:destroy)
    assert_nil @controller.session[:<%= model_file_name %>]
    assert_response :redirect
  end

  def test_should_remember_me
    @controller.params.merge!(:login => 'quentin', :password => 'test', :remember_me => '1')
    @controller._dispatch(:create)
    assert_not_nil @controller.cookies["auth_token"]
  end

  def test_should_not_remember_me
    @controller.params.merge!(:login => 'quentin', :password => 'test', :remember_me => '0')
    @controller._dispatch(:create)
    assert_nil @controller.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    @controller._dispatch(:destroy)
    assert_nil @controller.cookies["auth_token"]
  end

  def test_should_login_with_cookie
    @user.remember_me
    @controller.cookies["auth_token"] = @<%= singular_name %>.remember_token
    @controller._dispatch(:new)
    assert @controller.send(:logged_in?)
  end
  
  def test_should_fail_expired_cookie_login
    @<%= singular_name %>.remember_me
    @<%= singular_name %>.remember_token_expires_at = (Time.now - (5 * 60))
    @<%= singular_name %>.save
    @controller.cookies["auth_token"] = @<%= singular_name %>.remember_token
    @controller._dispatch(:new)
    assert !(@controller.send(:logged_in?))
  end
  
  def test_should_fail_cookie_login
    @<%= singular_name %>.remember_me
    @controller.cookies["auth_token"] = 'invalid_auth_token'
    @controller._dispatch(:new)
    assert !@controller.send(:logged_in?)
  end

  protected
    
    def login_as(login = :quentin)
      <%= singular_name %> = <%= class_name %>.find_with_conditions(:login => login.to_s)
      @controller.session[:<%= singular_name %>] = <%= singular_name %> ? <%= singular_name %>.id : nil
    end
end
