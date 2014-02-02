require 'yaml'

class New::Task
  def self.inherited task_class
    task_class.name = caller.first[/[a-z_]+?(?=\.rb)/].to_sym
  end

  def initialize project_config
    @project_config = project_config
    run
  end

  def self.name= name
    @name = name
  end
  def self.name; @name; end
  def name; self.class.name.to_sym; end

  # Return ALL available options
  #
  def project_options
    custom_options = New.custom_config
    project_options = @project_config

    all_options = custom_options.deep_merge(project_options)
    all_options[:tasks] ||= {}
    all_options[:tasks][name] ||= {}

    @project_options ||= all_options
  end

  # Return only the options for the given task
  #
  def options
    default_options = self.class::OPTIONS rescue {}
    @options ||= default_options.deep_merge(project_options[:tasks][name])
  end
end
