module AuthenticatedSystem
  module OrmMap
    
    def find_authenticated_model_with_id(id)
      UserModel.find_by_id(id)
    end
    
    def find_authenticated_model_with_remember_token(rt)
      UserModel.find_by_remember_token(rt)
    end
    
    def find_activated_authenticated_model_with_login(login)
      if UserModel.instance_methods.include?("activated_at")
        UserModel.find(:first, :conditions => ["login=? AND activated_at IS NOT NULL", login])
      else
        UserModel.find_by_login(login)
      end
    end
    
    def find_activated_authenticated_model(activation_code)
      UserModel.find_by_activation_code(activation_code)
    end  
    
    def find_with_conditions(conditions)
      UserModel.find(:first, :conditions => conditions)
    end
    
    # A method to assist with specs
    def clear_database_table
      UserModel.delete_all
    end
  end
  
end