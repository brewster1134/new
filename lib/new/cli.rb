require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'semantic'
require 'thor'

class New::Cli < Thor
  desc 'init', 'Create a default configuration file in your home directory'
  def init
    home_newfile = File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME)

    if File.file? home_newfile
      S.ay 'A `Newfile` already exists in your home directory', :warn
    else
      File.open(home_newfile, 'w') do |f|
        f.write(New::DEFAULT_NEWFILE.deep_stringify_keys.to_yaml)
      end
      S.ay "`#{home_newfile}` was successfully created", :success
    end
  end

  desc 'tasks', 'List all available tasks'
  def tasks
    S.ay 'Fetching sources...', :success

    New.load_newfiles
    New::Source.load_sources

    New::Source.sources.each do |source_name, source|
      S.ay source_name.to_s, :newline => false, :style => [:bold, :underline]
      S.ay ' => ', :newline => false
      S.ay source.path, :color => :blue

      source.tasks.keys.each do |task_name|
        S.ay task_name.to_s, :indent => 2, :color => :green
      end

      S.ay
    end
  end

  desc 'release', 'Release a new version of your project'
  def release
    New.set_cli
    New.load_newfiles

    version = Semantic::Version.new New.version

    # request the version to bump
    S.ay "           Current Version: #{version.to_s.green}", type: :success
    A.sk "  What do you want to bump: [#{'Mmp'.green}] (#{'M'.green}ajor / #{'m'.green}inor / #{'p'.green}atch)" do |response|
      case response
      when 'M'
        version.major += 1
        version.minor = 0
        version.patch = 0
      when 'm'
        version.minor += 1
        version.patch = 0
      when 'p'
        version.patch += 1
      end
    end
    S.ay "               New Version: #{version.to_s.green}", type: :success

    New.new version.to_s
  end

  desc 'version', 'Show the current version'
  def version
    New.load_newfiles
    S.ay New.new_object[:name], :newline => false
    S.ay New.new_object[:version], :color => :green, :indent => 1
  end

  default_task :release
end
