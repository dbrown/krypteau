class AuthenticatedGenerator < Merb::GeneratorBase
  
  default_options :author => nil
  
  attr_reader   :name,  
                :class_name, 
                :class_path, 
                :model_file_name, 
                :class_nesting, 
                :class_nesting_depth, 
                :plural_name, 
                :singular_name,
                :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name
  attr_reader   :model_controller_name,
                :model_controller_class_path,
                :model_controller_file_path,
                :model_controller_class_nesting,
                :model_controller_class_nesting_depth,
                :model_controller_class_name,
                :model_controller_singular_name,
                :model_controller_plural_name
  alias_method  :model_controller_file_name,  :model_controller_singular_name
  alias_method  :model_controller_table_name, :model_controller_plural_name
  attr_reader   :include_activation,
                :controller_view_path, 
                :model_controller_view_path,
                :controller_full_path,
                :model_controller_full_path
  
  def initialize(runtime_args, runtime_options = {})
    @base = File.dirname(__FILE__)
    super
    extract_options
    assign_names!(runtime_args.shift)
    @include_activation = options[:include_activation]
    
    @controller_name = runtime_args.shift || 'sessions'
    @model_controller_name = @name.pluralize
    @mailer_controller_name = @name
    
    # sessions controller
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    @controller_full_path = File.join(controller_class_path, controller_file_name)
    @controller_view_path = File.join("app/views", @controller_full_path)

    # model controller
    base_name, @model_controller_class_path, @model_controller_file_path, @model_controller_class_nesting, @model_controller_class_nesting_depth = extract_modules(@model_controller_name)
    @model_controller_class_name_without_nesting, @model_controller_singular_name, @model_controller_plural_name = inflect_names(base_name)
    
    if @model_controller_class_nesting.empty?
      @model_controller_class_name = @model_controller_class_name_without_nesting
    else
      @model_controller_class_name = "#{@model_controller_class_nesting}::#{@model_controller_class_name_without_nesting}"
    end    
    @model_controller_full_path = File.join(model_controller_class_path, model_controller_file_name)
    @model_controller_view_path = File.join("app/views", @model_controller_full_path)
  end

  def manifest
    manifest_result = record do |m|
      @m = m
          
      @choices = []
      @choices << "app/mailers"
      Dir[File.join(@base, "templates", "app", "mailers", "**", "*")].each do |f|
        @choices << relative(f)
      end
      
      @choices.each do |f|
        options[f] = options[:include_activation] ? true : false
      end

      @assigns = {
        :class_name                               => class_name,
        :class_path                               => class_path, 
        :model_file_name                          => model_file_name, 
        :class_nesting                            => class_nesting, 
        :class_nesting_depth                      => class_nesting_depth, 
        :plural_name                              => plural_name, 
        :singular_name                            => singular_name,
        :include_activation                       => options[:include_activation],
        :controller_name                          => controller_name,
        :controller_class_path                    => controller_class_path,
        :controller_file_path                     => controller_file_path,
        :controller_class_nesting                 => controller_class_nesting,
        :controller_class_nesting_depth           => controller_class_nesting_depth,
        :controller_class_name                    => controller_class_name,
        :controller_singular_name                 => controller_singular_name,
        :controller_plural_name                   => controller_plural_name,
        :model_controller_name                    => model_controller_name,
        :model_controller_class_path              => model_controller_class_path,
        :model_controller_file_path               => model_controller_file_path,
        :model_controller_class_nesting           => model_controller_class_nesting,
        :model_controller_class_nesting_depth     => model_controller_class_nesting_depth,
        :model_controller_class_name              => model_controller_class_name,
        :model_controller_singular_name           => model_controller_singular_name,
        :model_controller_plural_name             => model_controller_plural_name,
        :controller_view_path                     => controller_view_path,
        :model_controller_view_path               => model_controller_view_path,
        :controller_full_path                     => controller_full_path,
        :model_controller_full_path               => model_controller_full_path
      }
      
      # Do these first to allow an error to be raised
      m.dependency "merbful_authentication_tests", [name], @assigns
      m.dependency "merbful_authentication_model", [name], @assigns
      
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/controllers', model_controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/controllers', model_controller_class_path)
      m.directory File.join('app/helpers', model_controller_class_path)
      
      copy_dirs
      copy_files
      

      # Add the call to include authenticated_dependencies in init.rb 
      dr = @destination_root
      init_path = File.join(dr,"config","init.rb")
      if File.open(init_path){ |f| f.read !~ /authenticated_dependencies/ }
        File.open(init_path, "a") do |f|
          o =<<-END

begin 
  require File.join(File.dirname(__FILE__), '..', 'lib', 'authenticated_system/authenticated_dependencies') 
rescue LoadError
end
END
          f << o
        end
      end
      
      # Add the routes to routes.rb
      rp = File.join(dr,"config","router.rb")
      if File.open(rp){|f| f.read !~ /AuthenticatedSystem/ }
        File.open(rp, 'a') do |f|
          f << "\n\nAuthenticatedSystem.add_routes rescue nil\n"
        end
      end   
      
    end
    
    action = nil
    action = $0.split("/")[1]
    case action
    when 'generate'
      puts finishing_message
    when 'destroy'
      puts "Thanx for using merbful_authentication"
    end
    
    manifest_result
    
  end

  protected
  # Override with your own usage banner.
  def banner
    out = <<-EOD;
    Usage: #{$0} authenticated ModelName [ControllerName]  
    EOD
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration", 
           "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    opt.on("--include-activation", 
           "Generate signup 'activation code' confirmation via email") { |v| options[:include_activation] = true }
  end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
    
    
    # Borrowed from RailsGenerators
    # Extract modules from filesystem-style or ruby-style path:
    #   good/fun/stuff
    #   Good::Fun::Stuff
    # produce the same results.
    def extract_modules(name)
      modules = name.include?('/') ? name.split('/') : name.split('::')
      name    = modules.pop
      path    = modules.map { |m| m.underscore }
      file_path = (path + [name.underscore]).join('/')
      nesting = modules.map { |m| m.camelize }.join('::')
      [name, path, file_path, nesting, modules.size]
    end
    
    def inflect_names(name)
      camel  = name.camelize
      under  = camel.underscore
      plural = under.pluralize
      [camel, under, plural]
    end
    
    def assign_names!(name)
      @name = name.singularize
      base_name, @class_path, @model_file_name, @class_nesting, @class_nesting_depth = extract_modules(@name)
      @class_name_without_nesting, @singular_name, @plural_name = inflect_names(base_name)
      @table_name = @name.pluralize
      # @table_name = (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names) ? plural_name : singular_name
      @table_name.gsub! '/', '_'
      if @class_nesting.empty?
        @class_name = @class_name_without_nesting
      else
        @table_name = @class_nesting.underscore << "_" << @table_name
        @class_name = "#{@class_nesting}::#{@class_name_without_nesting}"
      end
    end
    
    private 
    
    def finishing_message
      output = <<-EOD
#{"-" * 70}
Don't forget to:
    
  - add named routes for authentication.  These are currently required
    In config/router.rb
    
      r.resources :#{plural_name}
      r.match("/login").to(:controller => "#{controller_class_name}", :action => "create").name(:login)
      r.match("/logout").to(:controller => "#{controller_class_name}", :action => "destroy").name(:logout)
EOD
    if options[:include_activation]
      output << "      r.match(\"/#{plural_name}/activate/:activation_code\").to(:controller => \"#{model_controller_class_name}\", :action => \"activate\").name(:#{singular_name}_activation)"
    end
    
    output << "\n\n" << ("-" * 70)
  end

    
end