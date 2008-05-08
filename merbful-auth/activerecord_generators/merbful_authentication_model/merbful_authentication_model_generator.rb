class MerbfulAuthenticationModelGenerator < Merb::GeneratorBase
  
  attr_reader   :name,  
                :class_name, 
                :class_path, 
                :model_file_name, 
                :class_nesting, 
                :class_nesting_depth, 
                :plural_name, 
                :singular_name,
                :include_activation,
                :migration_name,
                :migration_file_name
  
  def initialize(runtime_args, runtime_options = {})
    @base = File.dirname(__FILE__)
    super
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
      
      highest_migration = Dir[Dir.pwd+'/schema/migrations/*'].map{|f| File.basename(f) =~ /^(\d+)/; $1}.max
      @migration_file_name = format("%03d_%s", (highest_migration.to_i+1), "create_#{plural_name}")
      @migration_name = "Create#{plural_name.camelcase.gsub(/::/,'')}"
      
      @assigns = { 
                 :name => name,  
                 :class_name => class_name,
                 :class_path => class_path, 
                 :model_file_name => model_file_name, 
                 :class_nesting => class_nesting, 
                 :class_nesting_depth => class_nesting_depth, 
                 :plural_name => plural_name, 
                 :singular_name => singular_name,
                 :include_activation => options[:include_activation],
                 :migration_name  => migration_name,
                 :migration_file_name => migration_file_name
      }
      
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