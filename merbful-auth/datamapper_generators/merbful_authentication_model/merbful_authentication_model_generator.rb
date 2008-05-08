class MerbfulAuthenticationModelGenerator < Merb::GeneratorBase

  attr_reader   :name,  
                :class_name, 
                :class_path, 
                :model_file_name, 
                :class_nesting, 
                :class_nesting_depth, 
                :plural_name, 
                :singular_name,
                :include_activation
  
  def initialize(runtime_args, runtime_options = {})
    @base = File.dirname(__FILE__)
    super
    @name = args.shift
    runtime_options.each do |k,v| 
      ivar_name = "@#{k}"
      self.instance_variable_set("@#{k}", v) unless ivar_name.include?("/")  
    end
  end

  def manifest
    record do |m|
      @m = m
      @assigns = {
        :name                 => name,  
        :class_name           => class_name,
        :class_path           => class_path, 
        :model_file_name            => model_file_name, 
        :class_nesting        => class_nesting, 
        :class_nesting_depth  => class_nesting_depth, 
        :plural_name          => plural_name, 
        :singular_name        => singular_name,
        :include_activation   => include_activation
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
end