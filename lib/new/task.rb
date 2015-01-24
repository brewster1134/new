class New::Task
  @@tasks = {}

  # when custom task is required to the global task hash to initialize later
  #
  def self.inherited subclass
    name = subclass.to_s.downcase.to_sym
    New::Task.add_task name, subclass
  end

  # add task to global hash
  # @param name [String] task name taken from task directory
  # @param task [Task] new task class
  #
  def self.add_task name, task
    @@tasks[name.to_sym] = task
  end

private

    # require task and have it added to the global hash
    #
    def initialize path
      require path.sub(/\.rb$/, '')
    end
end
