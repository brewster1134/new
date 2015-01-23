require 'active_support/core_ext/hash/keys'
require 'cli_miami'
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
        S.ay task_name, :newline => false, :indent => source_name.to_s.length + 1, :color => :green
        S.ay ' => ', :newline => false
        S.ay "#{source_name}##{task_name}", :color => :blue, :style => :bright
      end

      S.ay
    end
  end

  desc 'release', 'Release a new version of your project'
  def release
  end

  desc 'version', 'Show the current version'
  def version
  end

  default_task :release
end
