class New
  require 'new/cli'

  HOME_DIRECTORY = File.expand_path '~'
  NEWFILE_NAME = 'Newfile'
  DEFAULT_NEWFILE = {
    :version => '0.0.0',
    :sources => {},
    :tasks => {},
  }

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
end


# require 'active_support/core_ext/hash/keys'
# require 'active_support/core_ext/object/deep_dup'
# require 'active_support/core_ext/string/inflections'
# require 'semantic'
# require 'yaml'

# class New; end
# # modules
# require 'new/dsl'
# require 'new/version'

# # classes
# require 'new/cli'
# require 'new/project'
# require 'new/source'
# require 'new/template'
# require 'new/task'

# class New
#   CONFIG_FILE = '.new'
#   GLOBAL_CONFIG_FILE = File.expand_path("~/#{CONFIG_FILE}")

#   def self.global_config
#     YAML.load(File.read(GLOBAL_CONFIG_FILE)).deep_symbolize_keys
#   end

#   def self.version
#     @version ||= Semantic::Version.new YAML.load(File.read(File.dirname(__FILE__) + "/../#{CONFIG_FILE}"))['version']
#   end
# end


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
