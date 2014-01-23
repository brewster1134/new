require 'thor'
require 'yaml'

class New::Cli < Thor
  desc '[TEMPLATE] [NAME]', "Create a new project with a given template (#{New.templates.join(' ')})"
  # option :name, required: true
  def method_missing method, *args
    if New.templates.include? method.to_sym
      # Split args that look like options (i.e start with - or --) into a separate array
      positional_args, opts = Thor::Options.split args

      # extract name from args
      name = positional_args[0]
      raise Thor::RequiredArgumentMissingError unless name

      # Add all options here
      # Make sure to include required options up above as well so they show in the help menu
      parser = Thor::Options.new(
      #   name: Thor::Option.new(:name, required: true, type: :string)
      )

      # The options hash is frozen in #initialize so you need to merge and re-assign
      self.options = options.merge(parser.parse(opts)).freeze

      # Dispatch the command
      project method, name
    else
      super
    end
  end

  desc 'init', 'Set up your home directory folder for storing custom templates and default configuration'
  def init
    if Dir.exists? New::CUSTOM_DIR
      New.say 'Home folder already exists.', type: :warn
    else
      # create folder
      New.say 'Creating home folder.', type: :success
      FileUtils.mkdir_p New::CUSTOM_DIR
      FileUtils.mkdir_p File.join(New::CUSTOM_DIR, New::TASKS_DIR_NAME)
      FileUtils.mkdir_p File.join(New::CUSTOM_DIR, New::TEMPLATES_DIR_NAME)

      # create config file
      New.say 'Creating default configuration file.', type: :success
      File.open File.join(New::CUSTOM_DIR, New::CONFIG_FILE), 'w' do |f|
        f.write New::Project::CUSTOM_CONFIG_TEMPLATE.to_yaml
      end

      New.say "Edit #{File.join(New::CUSTOM_DIR, New::CONFIG_FILE)} with your custom configuration details.", type: :warn
    end
  end

  desc 'release', 'Release your new code (Run from within a project directory!)'
  def release
    project_config_file = File.join(Dir.pwd,  New::CONFIG_FILE)
    raise unless File.exists? project_config_file

    project_config = YAML.load(File.open(project_config_file)).deep_symbolize_keys!
    tasks = project_config[:tasks].map{ |t| t.is_a?(Hash) ? t.keys.first.to_sym : t.to_sym }
    tasks.each do |task|
      # require custom task if it exists
      if New.custom_tasks.include? task
        require "#{New::CUSTOM_DIR}/#{New::TASKS_DIR_NAME}/#{task}/#{task}"
      else
        require "#{New::DEFAULT_DIR}/#{New::TASKS_DIR_NAME}/#{task}/#{task}"
      end
    end
  end

private

  def project template, name
    New::Project.new template, name
  end
end
