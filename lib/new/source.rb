require 'sourcerer'

class New::Source
  attr_reader :path, :tasks

  @@sources = {}
  def self.sources; @@sources; end

  # loop through sources saved to the global new object and initializes sources from them
  #
  def self.load_sources
    New.sources.each do |name, path|
      @@sources[name] = New::Source.new(path)
    end
  end

  # look through all sources to find a matching task
  # @param task_name [String/Symbol] valid task name
  # @param source_name [String/Symbol] valid source name
  #
  # @return [String] valid task path
  #
  def self.find_task_path task_name, source_name = nil
    # if source is specified, target it directly
    if source_name
      return @@sources[source_name.to_sym].tasks[task_name.to_sym]
      raise S.ay "`#{source_name}` did not contain a task called `#{task_name}`", :fail

    # otherwise loop through sources until a template is found
    else
      @@sources.values.each do |source|
        return source.tasks[task_name.to_sym] || next
      end

      raise S.ay "No task named `#{task_name}` could be found in any of the sources", :fail
    end
  end

private

    def initialize path
      @tasks = {}

      # fetch source and create tasks
      source = Sourcerer.new path
      source.files('**/*_task.rb').each do |task_file_path|
        task_name = task_file_path.match(/([^\/]*)_task\.rb$/)[1].to_sym
        @tasks[task_name] = task_file_path
      end

      # set path to sourcerer path
      @path = source.source
    end
end
