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
    @@new_object = {
      :sources => {
        :default => 'brewster1134/new-tasks'
      }
    }

    # access the current new object
    def new_object; @@new_object; end

    # set cli to true when initialized via cli
    def set_cli; @@cli = true; end

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

  def initialize version
    # load newfiles and sources
    New.load_newfiles unless @@cli
    New::Source.load_sources

    # update options with new version
    New.new_object = { :version => version }

    # run all tasks
    New.new_object[:tasks].each do |task_name, task_options|
      task = New::Source.find_task task_name, task_options.delete(:source).to_sym

      # collect options
      options = @@new_object.dup
      options.delete(:sources)
      options.delete(:tasks)
      options[:task_options] = task_options

      # run task
      task.run options
    end
  end
end
