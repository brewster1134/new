require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'listen'
require 'pp'
require 'semantic'
require 'thor'
require 'yaml'

CliMiami.set_preset :prompt, :color => :green
CliMiami.set_preset :highlight_key, :style => :bold
CliMiami.set_preset :highlight_value, :color => :blue, :style => :bright
CliMiami.set_preset :task_source, :color => :white, :style => [:bold, :underline]
CliMiami.set_preset :task_path, :color => :blue, :style => :underline

class New::Cli < Thor
  desc 'init', 'Create a Newfile for your project'
  option :name, :type => :string, :aliases => ['-n'], :default => '', :desc => 'Your project name'
  option :version, :type => :string, :aliases => ['-v'], :default => '', :desc => 'Your project\'s current version'
  option :tasks, :type => :array, :aliases => ['-t'], :default => [], :desc => 'Tasks to run when releasing your project'
  def init
    New.load_newfiles
    New::Source.load_sources

    # initialize empty newfile object
    newfile_object = {
      :tasks => {}
    }

    # get valid name
    name = @options['name']
    until !name.empty?
      name = A.sk 'Project Name:', :prompt
    end
    newfile_object[:name] = name

    # get valid version
    version = Semantic::Version.new(@options['version']) rescue nil
    until !version.to_s.empty?
      begin
        response = A.sk 'Current Version:', :prompt
        version = Semantic::Version.new response
      rescue
        S.ay "`#{response}` is not a valid semantic version", :fail
      end
    end
    newfile_object[:version] = version.to_s

    # get tasks
    tasks_list = []
    @options['tasks'].each do |task|
      tasks_list << New::Source.find_task(task)
    end

    # remove any nil tasks in case the user passed an invalid task
    tasks_list.compact!

    # if no tasks are specified, show available tasks
    if tasks_list.empty?
      S.ay
      self.tasks :show_source => true, :load_newfiles => false, :load_sources => false

      S.ay 'Enter tasks one at a time in the order you want them to run'
      S.ay 'To finish, press enter with nothing entered'

      added_task = nil
      until added_task == '' && !tasks_list.empty?
        S.ay
        added_task = A.sk 'Add a task:', :prompt

        # if a task is entered, verify it exists
        unless added_task.empty?

          # find task
          task = New::Source.find_task added_task

          # add task to array
          if task
            tasks_list << task
          end
        end
      end

      S.ay
    end

    # output the summary so far (no task options entered yet)
    S.ay 'Name: ', :preset => :highlight_key, :newline => false
    S.ay name, :highlight_value
    S.ay 'Version: ', :preset => :highlight_key, :newline => false
    S.ay version.to_s, :highlight_value
    S.ay 'Tasks: ', :highlight_key
    tasks_list.each do |task|
      S.ay "#{task.source.name}##{task.name}", :preset => :highlight_value, :indent => 2
    end
    S.ay

    tasks_list.each do |task|
      S.ay 'Set options for: ', :newline => false, :preset => :highlight_key
      S.ay task.name.to_s, :highlight_value
      S.ay

      newfile_object[:tasks][task.name] = {}
      task.options.each do |option_name, option_settings|
        S.ay option_name.to_s, :preset => :highlight_key
        S.ay option_settings[:description], :preset => :highlight_value, :indent => 2

        # show default
        default = option_settings[:default]
        if default
          default = case default
          when Array then default.join(', ')
          when Hash then default
          else default.to_s
          end

          S.ay 'default: ', :newline => false, :indent => 2
          S.ay default, :highlight_value
        end

        option_value = nil

        # GET USER INPUT FOR ARRAY TYPE
        #
        case

        # collect array option type values
        when option_settings[:type] == Array
          # cast type onto all user input values (default is String)
          klass = option_settings[:validation] || String

          # collect array elements from the user
          option_value = nil
          until option_value
            option_value = get_array_from_user(klass)
            option_value = task.validate_option(option_name, option_value) rescue nil
          end

        # collect hash option type values
        when option_settings[:type] == Hash
          # get the expected key names from either an Array or Hash
          option_keys = (option_settings[:validation].keys rescue option_settings[:validation]) || []

          # loop through the expected keys from the validation and get users input
          option_value = nil
          until option_value
            option_value = get_hash_from_user(*option_keys)
            option_value = task.validate_option(option_name, option_value) rescue nil
          end

        # collect non array/hash option type value
        else
          option_value = nil
          until option_value
            A.sk '', :newline => false, :preset => :prompt do |response|
              option_value = task.validate_option(option_name, response) rescue nil
            end
          end
        end

        newfile_object[:tasks][task.name][option_name] = option_value
        S.ay
      end
    end

    # write project Newfile
    project_newfile = File.join New::PROJECT_DIRECTORY, New::NEWFILE_NAME
    File.open project_newfile, 'w+' do |f|
      f.write newfile_object.deep_stringify_keys.to_yaml
    end
  end

  desc 'tasks', 'List all available tasks'
  def tasks args = {}
    # merge into default options
    args.reverse_merge!({
     :show_source => false,
     :load_newfiles => true,
     :load_sources => true
    })

    New.load_newfiles if args[:load_newfiles]
    if args[:load_sources]
      S.ay 'Fetching sources...', :prompt
      S.ay
      New::Source.load_sources
    end

    New::Source.sources.each do |source_name, source|
      S.ay source_name.to_s, :preset => :task_source, :newline => false, :indent => 1#, :padding => padding, :justify => :rjust
      S.ay source.path, :preset => :task_path, :indent => 1

      # determine the widest task & add some padding
      padding = source.tasks.keys.map(&:length).max + 4

      source.tasks.each do |task_name, task|
        if args[:show_source]
          S.ay "#{source_name}#", :preset => :highlight_value, :indent => 1, :newline => false
          S.ay task_name.to_s, :preset => :highlight_key, :padding => padding, :justify => :ljust, :newline => false
        else
          S.ay task_name.to_s, :preset => :highlight_value, :padding => padding, :justify => :ljust, :newline => false, :indent => 3
        end
        S.ay task.description
      end

      S.ay
    end
  end

  desc 'release', 'Release a new version of your project'
  def release
    New.set_cli
    New.load_newfiles

    version = Semantic::Version.new New.new_object[:version]

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
    sources = if @options['source']
      source_name = @options['source'].to_sym
      source_hash = {}
      source_hash[source_name] = New::Source.sources[source_name]
      source_hash
    else
      New::Source.sources
    end

    sources.each do |source_name, source|
      next unless source

      # create a hash with a single task if one is passed
      tasks = @options['task'] ? [source.tasks[options['task'].to_sym]] : source.tasks
      tasks = if @options['task']
        task_name = @options['task'].to_sym
        task_hash = {}
        task_hash[task_name] = source.tasks[task_name]
        task_hash
      else
        source.tasks
      end

      tasks.each do |task_name, task|
        next unless task.path

        spec_path = File.join(File.dirname(task.path), "#{task_name}_task_spec.rb")

        # if the source/task has a spec file, and the source is local, watch the task directory for changes and run the spec whenever anything changes
        if File.file?(spec_path) && File.directory?(source.path)
          # find task directory in original path, not the sourcerer tmp directory
          original_task_dir_path = File.dirname(Dir[File.join(source.path, '**', File.basename(task.path))][0])

          watch_dirs << original_task_dir_path
        end

        S.ay "Running tests for `#{task_name}` task in `#{source_name}` source...", :warn
        Kernel::system "bundle exec rspec #{spec_path}"
      end
    end

    # if watch files are found, start a listener to run the spec
    if @options['watch'] && !watch_dirs.empty?
      listener = Listen.to *watch_dirs do |modified, added, removed|
        all = modified + added + removed

        # find sibling spec file from modified file
        spec_path = all.collect{ |file| Dir[File.join(File.dirname(file), '*_spec.rb')] }.flatten.first

        Kernel::system "bundle exec rspec #{spec_path}"
      end
      listener.start
      Kernel::sleep
    end
  end

  no_commands do
    def get_array_from_user klass
      S.ay 'Add multiple values by pressing ENTER after each one. Enter an empty value to finish.'

      user_array = []
      user_response = nil

      # add to the array until an empty string is entered
      until user_response == ''
        A.sk user_array.compact.join(', '), :preset => :prompt do |response|

          # if the option is valid, pass through the empty string to end entering values
          if response.empty?
            user_response = ''
            next
          end

          user_response = New::Task.validate_class(response, klass) rescue nil
          user_array << user_response
        end
      end

      return user_array.compact
    end

    def get_hash_from_user *keys
      user_hash = {}
      user_response = nil

      keys.each do |key|
        A.sk "Enter a VALUE for `#{key}`", :prompt do |response|
          user_hash[key] = response
          S.ay user_hash
        end
      end

      until user_response == ''
        A.sk 'Enter a KEY name', :prompt do |key_response|
          # exit loop if user is done entering info
          if key_response == ''
            user_response = ''
            next
          end

          A.sk "Enter a VALUE for `#{key_response}`", :prompt do |value_response|
            user_hash[key_response.to_sym] = value_response
            S.ay user_hash
          end
        end

      end

      return user_hash
    end
  end

  default_task :release
end
