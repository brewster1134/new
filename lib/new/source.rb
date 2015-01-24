require 'sourcerer'

class New::Source
  @@sources = {}
  def self.sources; @@sources; end

  # loop through sources saved to the global new object and initializes sources from them
  #
  def self.load_sources
    New.sources.each do |name, path|
      @@sources[name] = New::Source.new(path)
    end
  end

private

    def initialize path
      @path = path
      @tasks = {}

      # fetch source and create tasks
      source = Sourcerer.new @path
      source.files('**/*_task.rb').each do |task_file_path|
        task_path = File.dirname task_file_path
        task_name = File.basename task_path

        @tasks[task_name] = New::Task.new task_file_path
      end
    end
end
