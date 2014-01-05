require 'yaml'

class New::Template
  CUSTOM_FOLDER = File.join(Dir.home, '.new')
  CUSTOM_TEMPLATES = File.join(CUSTOM_FOLDER, 'templates')
  CUSTOM_CONFIG_FILE = File.join(CUSTOM_FOLDER, '.new')
  CUSTOM_CONFIG_TEMPLATE = {
    'license' => '[LICENSE]',
    'developer' => {
      'name' => '[NAME]',
      'email' => '[EMAIL]',
    }
  }

  attr_accessor :options, :project_dir, :template, :custom

  # Create all variables and run new project creation methods
  #
  def initialize template, options
    @template = template
    @options = options
    @project_dir = File.join(Dir.pwd, options[:name]) # the newly created project directory

    copy_dir
    create_project_config
    process_erb_files
  end

  private

  # Create the new project by copying the template directory
  #
  def copy_dir
    FileUtils.cp_r get_template_dir, project_dir
  end

  # Get the template directory to copy from
  #
  def get_template_dir
    if Dir.exists? File.join(CUSTOM_TEMPLATES, template.to_s)
      @custom = true
      File.join(CUSTOM_TEMPLATES, template.to_s)
    else
      File.join(New::TEMPLATES_DIR, template.to_s)
    end
  end

  # Create the .new configuration file in the new project
  #
  def create_project_config
    config_hash = {
      'template' => template,
      'project_name' => options[:name],
    }.merge get_config_file

    new_config = File.join(project_dir, '.new')
    File.open new_config, 'w' do |f|
      f.write(config_hash.to_yaml)
    end
  end

  # Get a custom config in the home dir, or use the default with placeholders
  #
  def get_config_file
    config = if File.exists? CUSTOM_CONFIG_FILE
      YAML.load(File.open(CUSTOM_CONFIG_FILE))
    else
      CUSTOM_CONFIG_TEMPLATE
    end

    # Add a custom: true to config if a custom template is found
    if @custom
      config = config.merge({
        'custom' => true
      })
    end

    config
  end

  def process_erb_files
    Dir.glob(File.join(project_dir, '**/*.erb')).each do |file|
      process_erb_file file
    end
  end

  def process_erb_file file
    # Process the erb file
    processed_file = ERB.new(File.read(file)).result

    # Overwrite the original file with the processed file
    File.open file, 'w' do |f|
      f.write processed_file
    end

    # Remove the .erb from the file name
    File.rename file, file.chomp('.erb')
  end
end
