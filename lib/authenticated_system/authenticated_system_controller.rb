module AuthenticatedSystem
  module Controller
    protected
      # Returns true or false if the user_model is logged in.
      # Preloads @current_user_model with the user_model model if they're logged in.
      def logged_in?
        current_user_model != :false
      end
    
      # Accesses the current user_model from the session.  Set it to :false if login fails
      # so that future calls do not hit the database.
      def current_user_model
        @current_user_model ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
      end
    
      # Store the given user_model in the session.
      def current_user_model=(new_user_model)
        session[:user_model] = (new_user_model.nil? || new_user_model.is_a?(Symbol)) ? nil : new_user_model.id
        @current_user_model = new_user_model
      end
    
      # Check if the user_model is authorized
      #
      # Override this method in your controllers if you want to restrict access
      # to only a few actions or if you want to check if the user_model
      # has the correct rights.
      #
      # Example:
      #
      #  # only allow nonbobs
      #  def authorized?
      #    current_user_model.login != "bob"
      #  end
      def authorized?
        logged_in?
      end

      # Filter method to enforce a login requirement.
      #
      # To require logins for all actions, use this in your controllers:
      #
      #   before_filter :login_required
      #
      # To require logins for specific actions, use this in your controllers:
      #
      #   before_filter :login_required, :only => [ :edit, :update ]
      #
      # To skip this in a subclassed controller:
      #
      #   skip_before_filter :login_required
      #
      def login_required
        authorized? || throw(:halt, :access_denied)
      end

      # Redirect as appropriate when an access request fails.
      #
      # The default action is to redirect to the login screen.
      #
      # Override this method in your controllers if you want to have special
      # behavior in case the user_model is not authorized
      # to access the requested action.  For example, a popup window might
      # simply close itself.
      def access_denied
        case content_type
        when :html
          store_location
          redirect url(:login)
        when :xml
          headers["Status"]             = "Unauthorized"
          headers["WWW-Authenticate"]   = %(Basic realm="Web Password")
          set_status(401)
          render :text => "Couldn't authenticate you"
        end
      end
    
      # Store the URI of the current request in the session.
      #
      # We can return to this location by calling #redirect_back_or_default.
      def store_location
        session[:return_to] = request.uri
      end
    
      # Redirect to the URI stored by the most recent store_location call or
      # to the passed default.
      def redirect_back_or_default(default)
        loc = session[:return_to] || default
        session[:return_to] = nil
        redirect loc
      end
    
      # Inclusion hook to make #current_user_model and #logged_in?
      # available as ActionView helper methods.
      # def self.included(base)
      #   base.send :helper_method, :current_user_model, :logged_in?
      # end

      # Called from #current_user_model.  First attempt to login by the user_model id stored in the session.
      def login_from_session
        self.current_user_model = UserModel.find_authenticated_model_with_id(session[:user_model]) if session[:user_model]
      end

      # Called from #current_user_model.  Now, attempt to login by basic authentication information.
      def login_from_basic_auth
        user_modelname, passwd = get_auth_data
        self.current_user_model = UserModel.authenticate(user_modelname, passwd) if user_modelname && passwd
      end

      # Called from #current_user_model.  Finaly, attempt to login by an expiring token in the cookie.
      def login_from_cookie     
        user_model = cookies[:auth_token] && UserModel.find_authenticated_model_with_remember_token(cookies[:auth_token])
        if user_model && user_model.remember_token?
          user_model.remember_me
          cookies[:auth_token] = { :value => user_model.remember_token, :expires => user_model.remember_token_expires_at }
          self.current_user_model = user_model
        end
      end
    
      def reset_session
        session.data.each{|k,v| session.data.delete(k)}
      end

    private
      @@http_auth_headers = %w(Authorization HTTP_AUTHORIZATION X-HTTP_AUTHORIZATION X_HTTP_AUTHORIZATION REDIRECT_X_HTTP_AUTHORIZATION)

      # gets BASIC auth info
      def get_auth_data
        auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
        auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
        return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
      end
  end
end

Merb::BootLoader.after_app_loads do
  Application.send(:include, AuthenticatedSystem::Controller)
end