#
# New::Source represents a source (local or remote) that contains new tasks
#
require 'sourcerer'
class New::Source
  #
  # CLASS METHODS
  #
  class << self
    @@sources = {}
    def sources; @@sources; end

    # loop through sources saved to the global new object and initializes sources from them
    #
    def load_sources
      New.new_object[:sources].each do |name, path|
        @@sources[name] = New::Source.new name, path
      end
    end

    # look through all sources to find a matching task
    # @param task_name [String/Symbol] valid task name
    # @param source_name [String/Symbol] valid source name
    #
    # @return [String] valid task path
    #
    def find_task task_name, source_name = nil
      # if source is specified, target it directly
      if source_name
        return lookup_task source_name, task_name

      # if source and task is specified in a single string
      elsif task_name.to_s.include? '#'
        source_task = task_name.split('#').reverse
        source_name = source_task[1].to_sym
        task_name = source_task[0].to_sym

        return lookup_task source_name, task_name

      # otherwise loop through sources until a template is found
      else
        @@sources.values.each do |source|
          return source.tasks[task_name.to_sym] || next
        end
        S.ay "No `#{task_name}` task was found in any of the sources", :error
      end

      return nil
    end

  private

    # use the source and task names to get a task instance
    # @param source_name [Symbol] symbolized valid source name
    # @param task_name [Symbol] symbolized valid task name
    #
    # @return [New::Task|nil] returns a task, or nil if none is found
    #
    def lookup_task source_name, task_name
      if source = @@sources[source_name.to_sym]
        if task = source.tasks[task_name.to_sym]
          return task
        else
          S.ay "No `#{task_name}` task was found in the `#{source_name}` source", :error
        end
      else
        S.ay "No `#{source_name}` source was found", :error
      end

      return nil
    end
  end


  #
  # INSTANCE METHODS
  #
  attr_reader :name, :path, :tasks

private

  def initialize name, path
    @name = name
    @tasks = {}

    # fetch source and create tasks
    source = Sourcerer.new path
    source.files('**/*_task.rb').each do |task_file_path|
      # load task ruby file
      load task_file_path

      # get task name from task path
      task_name = New::Task.get_task_name task_file_path

      # lookup task from initialized global tasks
      task = New::Task.tasks[task_name]

      # unload class so it can be inherited again
      # this means once a class is loaded, it is inherited, initialized, then destroyed
      New.send :remove_const, task.class.to_s.sub('New::', '').to_sym

      # add source to task
      task.source = self

      # add global task to the source tasks object
      @tasks[task_name] = task
    end

    # set path to sourcerer path
    @path = source.source
  end
end
