require 'yaml'

class New::Task
  def self.inherited task_class
    @name = caller.first[/[a-z_]+?(?=\.rb)/].to_sym
    task_class.new get_options
  end

private

  def self.get_options
    @options ||= #YAML.load(File.open(project_config_file)).deep_symbolize_keys!
  end

  def get_task
    if New.custom_tasks.include? @name
    end
  end
end
