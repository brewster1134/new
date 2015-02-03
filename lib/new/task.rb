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

    task_gemfile_path = File.join(File.dirname(task_path), 'Gemfile')
    if File.file? task_gemfile_path
      system "bundle install --gemfile=#{task_gemfile_path}"
    end
  end
end
