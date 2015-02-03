require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'listen'
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

  desc 'test', 'Run task tests from sources'
  option :watch, :type => :boolean, :aliases => ['-w'], :desc => 'Watch local tasks for changes and run tests'
  option :source, :type => :string, :aliases => ['-s'], :desc => 'Source name'
  option :task, :type => :string, :aliases => ['-t'], :desc => 'Task name'
  def test
    watch_dirs = []

    New.load_newfiles
    New::Source.load_sources

    # create a hash with a single source if one is passed
    sources = if options['source']
      source_name = options['source'].to_sym
      source_hash = {}
      source_hash[source_name] = New::Source.sources[source_name]
      source_hash
    else
      New::Source.sources
    end

    sources.each do |source_name, source|
      next unless source

      # create a hash with a single task if one is passed
      tasks = options['task'] ? [source.tasks[options['task'].to_sym]] : source.tasks
      tasks = if options['task']
        task_name = options['task'].to_sym
        task_hash = {}
        task_hash[task_name] = source.tasks[task_name]
        task_hash
      else
        source.tasks
      end

      tasks.each do |task_name, task_path|
        next unless task_path

        spec_path = File.join(File.dirname(task_path), "#{task_name}_task_spec.rb")

        # if the source/task has a spec file, and the source is local, watch the task directory for changes and run the spec whenever anything changes
        if File.file?(spec_path) && File.directory?(source.path)
          # find task directory in original path, not the sourcerer tmp directory
          original_task_dir_path = File.dirname(Dir[File.join(source.path, '**', File.basename(task_path))][0])

          watch_dirs << original_task_dir_path
        end

        S.ay "Running tests for `#{task_name}` task in `#{source_name}` source...", :warn
        system "bundle exec rspec #{spec_path}"
      end
    end

    # if watch files are found, start a listener to run the spec
    if options['watch'] && !watch_dirs.empty?
      listener = Listen.to *watch_dirs do |modified, added, removed|
        all = modified + added + removed

        # find sibling spec file from modified file
        spec_path = all.collect{ |file| Dir[File.join(File.dirname(file), '*_spec.rb')] }.flatten.first

        system "bundle exec rspec #{spec_path}"
      end
      listener.start
      sleep
    end
  end

  default_task :release
end
