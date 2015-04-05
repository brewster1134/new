class New::Task
  extend New::Validation

  #
  # CLASS METHODS
  #
  class << self
    # global tasks for task class with a getter
    @@tasks = {}
    def tasks; @@tasks; end

    # derive a task name from a task path
    # @param task_path [String] full path to a task ruby file
    #
    def get_task_name task_path
      task_path.match(/([^\/]*)_task\.rb$/)[1].to_sym
    end

  private

    # when custom task is required, add the class to the global hash to initialize later
    #
    def inherited subclass
      # get task details from path
      path = caller.first.match(/(^.*_task\.rb).*$/)[1]
      name = get_task_name path

      # add subclass to global object for easier lookup
      @@tasks[name] = subclass.new name, path
    end
  end


  #
  # INSTANCE METHODS
  #
  attr_accessor :source, :options
  attr_reader :name, :path

  # getters/setters for task meta data stored temporarily on a class var
  def description
    @description ||= self.class.class_variable_get :@@description rescue ''
  end

  def class_options
    @class_options ||= self.class.class_variable_get :@@options rescue {}
  end

  # task to check that outside dependencies are met before we run the tasks
  # since verify is not a required method, we define a blank one to prevent undefined method errors
  #
  def verify; end

  # validate all options
  #
  def validate
    class_options.keys.each do |option_name|
      option_settings = class_options[option_name]
      option_value = @options[:task_options][option_name]
      new_option_value = New::Task.validate_option(option_name, option_settings, option_value)

      # set the new validated value
      @options[:task_options][option_name] = new_option_value
    end
  end

  # run a system command
  def run_command command
    # if verbose, dont redirect output to null
    command += ' >> /dev/null 2>&1' unless New.verbose

    # run the command
    Kernel.system command
  end

private

  def initialize name, path
    @name = name
    @path = path
  end
end
