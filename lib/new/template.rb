require 'erb'
require 'recursive-open-struct'
require 'yaml'

class New::Template
  CUSTOM_FOLDER = File.join(Dir.home, '.new')
  CUSTOM_TEMPLATES = File.join(CUSTOM_FOLDER, 'templates')
  CUSTOM_CONFIG_FILE = File.join(CUSTOM_FOLDER, '.new')
  CUSTOM_CONFIG_TEMPLATE = {
    license: '[LICENSE]',
    github: {
      username: '[USERNAME]'
    },
    developer: {
      name: '[NAME]',
      email: '[EMAIL]'
    }
  }

  attr_accessor :options, :project_dir, :template_options

  # Create all variables and run new project creation methods
  #
  def initialize template, name
    @project_dir = File.join(Dir.pwd, name) # the newly created project directory

    set_options template, name
    copy_dir
    create_config_file
    process_erb_files
  end

private

  # Create the options object
  #
  def set_options template, name
    # Check for custom config file
    custom_config_file = YAML.load(File.open(CUSTOM_CONFIG_FILE)).deep_symbolize_keys! rescue {}

    # merge options together
    config = CUSTOM_CONFIG_TEMPLATE.clone.merge!(custom_config_file).merge!({
      type: template,
      project_name: name
    })

    # Add a custom: true to config if a custom template is found
    if Dir.exists? File.join(CUSTOM_TEMPLATES, template.to_s)
      config.merge!({
        custom: true
      })
    end

    @options = config
  end

  # Create the new project by copying the template directory
  #
  def copy_dir
    FileUtils.cp_r get_template_dir, @project_dir
  end

  # Get the template directory to copy from
  #
  def get_template_dir
    if @options[:custom]
      File.join(CUSTOM_TEMPLATES, @options[:type].to_s)
    else
      File.join(New::TEMPLATES_DIR, @options[:type].to_s)
    end
  end

  # Create the .new configuration file in the new project
  #
  def create_config_file
    new_config = File.join(@project_dir, '.new')
    File.open new_config, 'w' do |f|
      yaml_options = Marshal.load(Marshal.dump(@options)).deep_stringify_keys!.to_yaml
      f.write(yaml_options)
    end
  end

  def process_erb_files
    # Convert options to OpenStruct so we can use dot notation in the templates
    @template_options = RecursiveOpenStruct.new(@options)

    Dir.glob(File.join(@project_dir, '**/*.erb')).each do |file|
      process_erb_file file
    end
  end

  def process_erb_file file
    # Process the erb file
    processed_file = ERB.new(File.read(file)).result(binding)

    # Overwrite the original file with the processed file
    File.open file, 'w' do |f|
      f.write processed_file
    end

    # Remove the .erb from the file name
    File.rename file, file.chomp('.erb')
  end

  # Allow templates to call option values directly
  def method_missing method
    @template_options.send(method.to_sym) || super
  end
end
