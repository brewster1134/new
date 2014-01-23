require 'erb'
require 'recursive-open-struct'
require 'yaml'

class New::Project
  # regex to match capital underscored template options names ie [PROJECT_NAME]
  FILENAME_RENAME_MATCH = /\[([A-Z_.]+)\]/
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

  # Create all variables and run new project creation methods
  #
  def initialize template, name
    @options = {}

    set_options template, name
    copy_template
    create_config_file
    rename_paths
    process_erb_files
  end

private

  # Create the options object
  #
  def set_options template, name
    @project_dir = File.join(Dir.pwd, name)   # the newly created project directory
    @template_dir = get_template_dir template # the template directory to copy

    # Check for custom config file
    custom_config_file = YAML.load(File.open(File.join(New::CUSTOM_DIR, New::CONFIG_FILE))).deep_symbolize_keys! rescue {}
    template_config_file = YAML.load(File.open(File.join(@template_dir, New::CONFIG_FILE))).deep_symbolize_keys! rescue {}

    # merge options together
    config = CUSTOM_CONFIG_TEMPLATE.clone.merge!(custom_config_file).merge!(template_config_file).merge!({
      type: template,
      project_name: name
    })

    @options.merge! config

    # Convert options to OpenStruct so we can use dot notation in the templates
    @template_options = RecursiveOpenStruct.new(@options)
  end

  # Create the new project by copying the template directory
  #
  def copy_template
    FileUtils.cp_r @template_dir, @project_dir
  end

  # Get the template directory to copy from
  #
  def get_template_dir template
    if New.custom_templates.include? template
      @options[:custom] = true
      File.join(New::CUSTOM_DIR, New::TEMPLATES_DIR_NAME, template.to_s)
    else
      File.join(New::DEFAULT_DIR, New::TEMPLATES_DIR_NAME, template.to_s)
    end
  end

  # Create the .new configuration file in the new project
  #
  def create_config_file
    new_config = File.join(@project_dir, New::CONFIG_FILE)
    File.open new_config, 'w' do |f|
      yaml_options = Marshal.load(Marshal.dump(@options)).deep_stringify_keys!.to_yaml
      f.write(yaml_options)
    end
  end

  # Collect ERB files to process
  #
  def process_erb_files
    Dir.glob(File.join(@project_dir, '**/*.erb'), File::FNM_DOTMATCH).each do |file|
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

  # Collect files with a matching value to interpolate
  #
  def rename_paths
    get_path = -> type do
      Dir.glob(File.join(@project_dir, '**/*')).select do |e|
        File.send("#{type}?".to_sym, e) && e =~ FILENAME_RENAME_MATCH
      end
    end

    # rename directories first
    get_path[:directory].each{ |dir| rename_path dir }
    get_path[:file].each{ |dir| rename_path dir }
  end

  # Interpolate filenames with template options
  #
  def rename_path path
    new_path = path.gsub FILENAME_RENAME_MATCH do
      # Extract interpolated values into symbols
      methods = $1.downcase.split('.').map(&:to_sym)

      # Call each method on options
      methods.inject(@template_options){ |options, method| options.send(method) }
    end

    if File.file?(path)
      File.rename path, new_path
    else
      FileUtils.mv path, new_path
    end
  end

  # Allow templates to call option values directly
  #
  def method_missing method
    @template_options.send(method.to_sym) || super
  end
end
