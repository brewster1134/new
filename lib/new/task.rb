require 'yaml'

class New::Task
  def self.inherited task_class
    task_class.name = caller.first[/[a-z_]+?(?=\.rb)/].to_sym
  end

  def initialize project_config
    @project_config = project_config
  end

  def self.name= name
    @name = name
  end

  def options
    default_task_options = self.class::OPTIONS rescue {}
    custom_task_options = New.custom_config[:tasks][@name] rescue {}
    project_task_options = @project_config[:tasks][@name] rescue {}

    @options ||= default_task_options.deep_merge(custom_task_options).deep_merge(project_task_options)
  end
end
