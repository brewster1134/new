class New::Task
  @@tasks = {}
  def self.tasks; @@tasks; end

  # when custom task is required, add the class to the global hash to initialize later
  #
  def self.inherited subclass
    # create name from task file name
    # e.g. foo_task.rb => `foo`
    task_name = caller.first.match(/([^\/]*)_task\.rb.*$/)[1].to_sym
    @@tasks[task_name] = subclass
  end

  def self.load task_path
    require task_path.sub(/\.rb$/, '')
  end
end
