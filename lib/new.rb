require 'active_support/core_ext/hash/deep_merge'
require 'yaml'

class New
  require 'new/cli'
  require 'new/source'
  require 'new/task'

  HOME_DIRECTORY = ENV['HOME']
  NEWFILE_NAME = 'Newfile'
  DEFAULT_NEWFILE = {
    :sources => {
      :default => 'brewster1134/new-tasks'
    }
  }

  @@cli = false

  @@new_object = DEFAULT_NEWFILE.dup
  def self.new_object; @@new_object; end

  # load Newfiles in home directory and pwd
  #
  def self.load_newfiles
    self.load_newfile File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME)
    self.load_newfile File.join(Dir.pwd, New::NEWFILE_NAME)
  end

  # load newfile contents into the global new object
  # @param newfile_path [String] path to a valid Newfile
  # @return [Hash] hash of newfile yaml contents
  #
  def self.load_newfile newfile_path
    # check file exists
    return false unless File.file? newfile_path

    # load Newfile yaml into global new_object hash
    self.new_object = YAML.load File.read newfile_path
  end

  # merge symbolized hash data into global new object
  # @param hash [Hash] any hash to be merged into existing data
  # @return [Hash] new merged data
  #
  def self.new_object= hash
    @@new_object.deep_merge! hash.deep_symbolize_keys
  end

  # allows helper accessors to look in new_object
  #
  def self.method_missing method
    value = @@new_object[method]
    defined?(value) ? value : super
  end

  # set the cli flag
  def self.set_cli; @@cli = true; end
  def self.cli; @@cli; end

private

    def initialize version
      New.load_newfiles unless @@cli
      New::Source.load_sources

      # copy the new object and remove other task options
      new_object = @@new_object.dup
      new_object.delete(:tasks)

      # find and load all task files
      New.tasks.each do |task_name, task_options|
        task_path = New::Source.find_task_path task_name, task_options.delete(:source)
        New::Task.load task_path
      end

      # run all tasks
      New.tasks.each do |task_name, task_options|
        New::Task.tasks[task_name].new new_object.deep_merge(task_options)
      end
    end
end
