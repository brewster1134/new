class New::Task
  # global tasks object with a getter
  @@tasks = {}
  def self.tasks; @@tasks; end

  # class setter for inherited related attributes
  def self.path= path
    @@path = path
  end
  def self.name= name
    @@name = name
  end

  # when custom task is required, add the class to the global hash to initialize later
  #
  def self.inherited subclass
    # get task details from path
    path = caller.first.match(/(^.*_task\.rb).*$/)[1]
    name = get_task_name path

    # set task details to the class
    subclass.path = path
    subclass.name = name

    # add subclass to global object for easier lookup
    @@tasks[name] = subclass
  end

  # derive a task name from a task path
  # @param task_path [String] full path to a task ruby file
  #
  def self.get_task_name task_path
    task_path.match(/([^\/]*)_task\.rb$/)[1].to_sym
  end

  #
  # INSTANCE METHODS
  #

  # instance getters for inherited related attributes
  def name; @@name; end
  def path; @@path; end

  # run bundler for task's Gemfile
  #
  def bundle_install
    task_gemfile_path = File.join(File.dirname(@@path), 'Gemfile')
    if File.file? task_gemfile_path
      system "bundle install --gemfile=#{task_gemfile_path}"
    end
  end
end
