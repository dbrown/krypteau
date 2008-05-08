class MerbfulAuthenticationTestsGenerator < Merb::GeneratorBase
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
                :controller_plural_name,
                :model_controller_name,
                :model_controller_class_path,
                :model_controller_file_path,
                :model_controller_class_nesting,
                :model_controller_class_nesting_depth,
                :model_controller_class_name,
                :model_controller_singular_name,
                :model_controller_plural_name,
                :include_activation
  
  def initialize(runtime_args, runtime_options = {})
    @base = File.dirname(__FILE__)
    super
    usage if args.empty?
    @name = args.shift
    extract_options
    runtime_options.each do |k,v| 
      ivar_name = "@#{k}"
      self.instance_variable_set("@#{k}", v) unless ivar_name.include?("/")  
    end
  end

  def manifest
    record do |m|
      
      @m = m
      # Ensure appropriate folder(s) exists
      @assigns = {
        :name                                 => name,  
        :class_name                           => class_name, 
        :class_path                           => class_path, 
        :model_file_name                      => model_file_name, 
        :class_nesting                        => class_nesting, 
        :class_nesting_depth                  => class_nesting_depth, 
        :plural_name                          => plural_name, 
        :singular_name                        => singular_name,
        :controller_name                      => controller_name,
        :controller_class_path                => controller_class_path,
        :controller_file_path                 => controller_file_path,
        :controller_class_nesting             => controller_class_nesting,
        :controller_class_nesting_depth       => controller_class_nesting_depth,
        :controller_class_name                => controller_class_name,
        :controller_singular_name             => controller_singular_name,
        :controller_plural_name               => controller_plural_name,
        :model_controller_name                => model_controller_name,
        :model_controller_class_path          => model_controller_class_path,
        :model_controller_file_path           => model_controller_file_path,
        :model_controller_class_nesting       => model_controller_class_nesting,
        :model_controller_class_nesting_depth => model_controller_class_nesting_depth,
        :model_controller_class_name          => model_controller_class_name,
        :model_controller_singular_name       => model_controller_singular_name,
        :model_controller_plural_name         => model_controller_plural_name,
        :include_activation                   => include_activation
      }
      
      @choices = []
      @choices << "spec/mailers"
      Dir[File.join(@base, "spec", "mailers")].each do |f|
        @choices << relative(f)
      end
      
      @choices.each do |f|
        options[f] = include_activation ? true : false
      end
      
      m.directory( File.join("spec", "controllers", controller_class_path))
      m.directory( File.join("spec", "controllers", model_controller_class_path))

      copy_dirs
      copy_files
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{$0} #{spec.name} name"
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end