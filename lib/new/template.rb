require 'yaml'

class New::Template
  TEMPLATES_DIR = File.expand_path('../../../templates', __FILE__)

  attr_accessor :options, :project_dir, :template, :template_dir

  # Create all variables and run new project creation methods
  #
  def initialize template, options
    @template = template
    @options = options
    @template_dir = File.join(TEMPLATES_DIR, template.to_s) # the template directory to copy
    @project_dir = File.join(Dir.pwd, options[:name])       # the newly created project directory

    copy_dir
    create_new_config
    process_erb_files
  end

  private

  # Create the new project by copying the template directory
  #
  def copy_dir
    FileUtils.cp_r template_dir, project_dir
  end

  # Create the .new configuration file in the new project
  #
  def create_new_config
    new_config = File.join(project_dir, '.new')

    File.open new_config, 'w' do |f|
      f.write({
        'template' => template
      }.to_yaml)
    end
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
