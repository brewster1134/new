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

  @@new_object = DEFAULT_NEWFILE.dup

  # CLI Miami presets
  CliMiami.set_preset :fail, {
    :color => :red
  }
  CliMiami.set_preset :warn, {
    :color => :yellow
  }
  CliMiami.set_preset :success, {
    :color => :green
  }

  # load all Newfiles
  #
  def self.load_newfiles
    New.load_newfile File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME)
    New.load_newfile File.join(Dir.pwd, New::NEWFILE_NAME)
  end

  def self.load_newfile newfile_path
    # check file exists
    return false unless File.file? newfile_path

    # load Newfile yaml into global new_object hash
    self.new_object = YAML.load File.read newfile_path
  end

private

    def self.new_object; @@new_object; end

    # allows helper accessors for new_object
    #
    def self.method_missing method
      value = self.new_object[method]
      defined?(value) ? value : super
    end

    def self.new_object= hash
      @@new_object.deep_merge! hash.deep_symbolize_keys
    end
end



private

    # Get a user input value for which semantic version part to bump
    #
    def get_part
      S.ay "            Current Version: #{New.version}", type: :success
      A.sk " Specify which part to bump: [#{'Mmp'.green}] (#{'M'.green}ajor / #{'m'.green}inor / #{'p'.green}atch)" do |part|
        case part
        when 'M'
          :major
        when 'm'
          :minor
        when 'p'
          :patch
        end
      end
    end
