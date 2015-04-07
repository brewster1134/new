require 'active_support/core_ext/hash/deep_merge'
require 'yaml'

# Allow true/false to respond to Boolean class
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

class New
  require 'new/validation'

  require 'new/cli'
  require 'new/source'
  require 'new/task'

  HOME_DIRECTORY = ENV['HOME']
  PROJECT_DIRECTORY = Dir.pwd
  NEWFILE_NAME = 'Newfile'

  #
  # CLASS METHODS
  #
  class << self
    @@cli = false
    @@verbose = false
    @@new_object = {
      :sources => {
        :default => 'brewster1134/new-tasks'
      }
    }

    # access the current new object
    def new_object; @@new_object; end

    # set cli to true when initialized via cli
    def set_cli; @@cli = true; end

    # set verbose to true when set via cli
    def set_verbose; @@verbose = true; end
    def verbose; @@verbose; end

    # Load Newfile in home & project directory
    #
    def load_newfiles
      load_newfile File.join(HOME_DIRECTORY, NEWFILE_NAME)
      load_newfile File.join(PROJECT_DIRECTORY, NEWFILE_NAME)
    end

    # Merge symbolized hash data into global new object
    #
    # @param hash [Hash] A hash to be merged into existing data
    #
    # @return [Hash] New merged data
    #
    def new_object= hash
      @@new_object.deep_merge! hash.deep_symbolize_keys
    end

  private

    # Load newfile contents into the global new object
    #
    # @param newfile_path [String] Path to a valid Newfile
    #
    # @return [Hash] Hash of Newfile yaml contents
    #
    def load_newfile newfile_path
      # check file exists
      return false unless File.file? newfile_path

      # load Newfile yaml into global new_object hash
      self.new_object = YAML.load File.read newfile_path
    end
  end

private

  def initialize version, changelog, *skip_tasks
    # load newfiles and sources
    New.load_newfiles unless @@cli
    New::Source.load_sources

    # update options with new attributes
    @@new_object[:version] = version
    @@new_object[:changelog] = changelog

    # create new options to pass to task
    new_options = @@new_object.dup
    new_options.delete(:sources)
    new_options.delete(:tasks)

    new_tasks = []
    @@new_object[:tasks].each do |task_name, task_options|
      # skip tasks
      next if skip_tasks.include? task_name.to_s

      S.ay "Preparing `#{task_name}`", :header

      # dupe task options
      new_task_options = task_options ? task_options.dup : {}

      # lookup and add task to array
      task = New::Source.find_task task_name, new_task_options.delete(:source)
      new_tasks << task

      # add task options
      new_options[:task_options] = new_task_options

      # set options
      task.options = new_options.dup

      # validate task before running anything
      S.ay 'Validating Options: ', :highlight_key
      task.validate
      S.ay 'OK', :highlight_value

      # verify tasks
      S.ay 'Verifying Task Dependencies: ', :highlight_key
      task.verify
      S.ay 'OK', :highlight_value
      S.ay
    end

    # write new Newfile with new version
    new_newfile = YAML.load(File.read(File.join(PROJECT_DIRECTORY, NEWFILE_NAME)))
    new_newfile['version'] = version
    File.open File.join(PROJECT_DIRECTORY, NEWFILE_NAME), 'w+' do |f|
      f.write new_newfile.to_yaml
    end

    new_tasks.each do |task|
      S.ay "Running `#{task.name}`", :header
      task.run
    end

    # release summary
    S.ay
    S.ay 'Version ', :newline => false
    S.ay "#{@@new_object[:version]}", :preset => :header, :newline => false
    S.ay ' of ', :newline => false
    S.ay "#{@@new_object[:name]}", :preset => :header, :newline => false
    S.ay ' successfully released!'
  end
end
