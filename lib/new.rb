class New
  VERSION = '0.0.1'
  DEFAULT_DIR = File.expand_path('../..', __FILE__)
  CUSTOM_DIR = File.expand_path('~/.new')
  TASKS_DIR_NAME = 'tasks'
  TEMPLATES_DIR_NAME = 'templates'
  CONFIG_FILE = '.new'

  # List all the available tasks
  #
  def self.tasks
    custom_tasks | default_tasks
  end

  # List all the available templates
  #
  def self.templates
    custom_templates | default_templates
  end

  def self.default_templates
    @default_templates ||= get_list TEMPLATES_DIR_NAME, :default
  end

  def self.custom_templates
    @custom_templates ||= get_list TEMPLATES_DIR_NAME, :custom
  end

  def self.default_tasks
    @default_tasks ||= get_list TASKS_DIR_NAME, :default
  end

  def self.custom_tasks
    @custom_templates ||= get_list TASKS_DIR_NAME, :custom
  end

private

  def self.get_list dir, filter
    case filter
    when :default
      Dir[File.join(DEFAULT_DIR, dir, '**')]
    when :custom
      Dir[File.join(CUSTOM_DIR, dir, '**')]
    end.map{ |d| File.basename(d).to_sym }
  end
end

require 'new/cli'
require 'new/dsl'
require 'new/objects'
require 'new/task'
require 'new/template'

class New
  extend New::Dsl
end
