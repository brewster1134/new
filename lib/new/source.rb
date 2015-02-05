require 'sourcerer'

class New::Source
  attr_reader :path, :tasks

  @@sources = {}
  def self.sources; @@sources; end

  # loop through sources saved to the global new object and initializes sources from them
  #
  def self.load_sources
    New.sources.each do |name, path|
      @@sources[name] = New::Source.new path
    end
  end

  # look through all sources to find a matching task
  # @param task_name [String/Symbol] valid task name
  # @param source_name [String/Symbol] valid source name
  #
  # @return [String] valid task path
  #
  def self.find_task task_name, source_name = nil
    # if source is specified, target it directly
    if source_name
      if source = @@sources[source_name]
        if task = source.tasks[task_name]
          return task
        else
          S.ay "`#{source_name}` did not contain a task called `#{task_name}`", :fail
        end
      else
        S.ay "The task `#{task_name}` set a source named `#{source_name}`, but no source could be found.", :fail
      end

    # otherwise loop through sources until a template is found
    else
      @@sources.values.each do |source|
        return source.tasks[task_name] || next
      end
      S.ay "No task named `#{task_name}` could be found in any of the sources", :fail
    end

    # if no task path is returned, exit
    exit
  end

private

    def initialize path
      @tasks = {}

      # fetch source and create tasks
      source = Sourcerer.new path
      source.files('**/*_task.rb').each do |task_file_path|
        # load task ruby file
        load task_file_path

        # add new task class to task object
        task_name = New::Task.get_task_name task_file_path
        @tasks[task_name] = New::Task.tasks[task_name]
      end

      # set path to sourcerer path
      @path = source.source
    end
end
