#
# New::Cli is a class built on Thor for interfacing with the user on the command line
#
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'listen'
require 'pp'
require 'semantic'
require 'thor'
require 'yaml'

CliMiami.set_preset :error, :color => :red
CliMiami.set_preset :fine_print, :color => :cyan
CliMiami.set_preset :header, :color => :green
CliMiami.set_preset :highlight_key, :indent => 2, :newline => false, :padding => 30, :justify => :rjust
CliMiami.set_preset :highlight_value, :color => :blue, :style => :bright, :indent => 1
CliMiami.set_preset :instruction, :color => :yellow, :indent => 2
CliMiami.set_preset :list_item, :indent => 2
CliMiami.set_preset :prompt, :color => :yellow, :style => :bold

# create a horizontal line
HR = -> {S.ay('-' * 32 , :header)}

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
        response = A.sk 'Current Project Version:', :prompt
        version = Semantic::Version.new response
      rescue
        S.ay "`#{response}` is not a valid semantic version (e.g. 1.2.3)", :error
      end
    end
    newfile_object[:version] = version.to_s

    # get tasks
    tasks_list = []
    @options['tasks'].each do |task|
      tasks_list << New::Source.find_task(task)
    end

    # remove any empty tasks in case the user specified an invalid task
    tasks_list.compact!

    # if no tasks are specified, show all available tasks
    if tasks_list.empty?
      S.ay
      self.tasks :show_source => true, :load_newfiles => false, :load_sources => false

      S.ay 'Add multiple tasks by pressing ENTER after each one', :instruction
      S.ay 'Enter tasks in the order you want them to run', :instruction
      S.ay 'Enter both the source and the task (e.g. source#task)', :instruction
      S.ay 'Enter an empty value to finish', :instruction

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
    padding = 10
    S.ay 'Name:', :preset => :highlight_key, :padding => padding
    S.ay name, :preset => :highlight_value
    S.ay 'Version:', :preset => :highlight_key, :padding => padding
    S.ay version.to_s, :preset => :highlight_value
    S.ay 'Tasks:', :preset => :highlight_key, :padding => padding

    # output first task without a padding so it looks nicer
    tasks_dup = tasks_list.dup
    first_task = tasks_dup.shift
    S.ay "#{first_task.source.name}##{first_task.name}", :highlight_value
    tasks_dup.each do |task|
      S.ay "#{task.source.name}##{task.name}", :preset => :highlight_value, :indent => padding + 3
    end
    S.ay

    tasks_list.each do |task|
      HR.call
      S.ay 'OK, now lets set options for', :highlight_key
      S.ay task.name.to_s.upcase, :highlight_value
      HR.call
      S.ay

      newfile_object[:tasks][task.name] = {}
      task.class_options.each do |option_name, option_settings|
        S.ay option_name.to_s, :preset => :highlight_key, :padding => 0
        S.ay option_settings[:description], :highlight_value

        # show default
        default = option_settings[:default]
        if default && !option_settings[:required]
          default = case default
          when Array then default.join(', ')
          when Hash then default.keys.join(', ')
          else default.to_s
          end

          S.ay "default: #{default}", :preset => :fine_print, :indent => option_name.length + 3
        end

        # GET USER INPUT FOR ARRAY TYPE
        #
        option_type = option_settings[:type]
        case

        # collect array option type values
        when option_type == Array
          # cast type onto all user input values (default is String)
          klass = option_settings[:validation] || String

          # collect array elements from the user
          option_value = nil
          until option_value
            begin
              option_value = get_array_from_user(klass)
              option_value = New::Task.validate_option(option_name, option_settings, option_value)
            rescue
              option_value = nil
            end
          end

        # collect hash option type values
        when option_type == Hash
          # loop through the expected keys from the validation and get users input
          option_value = nil
          until option_value
            begin
              option_value = get_hash_from_user(option_settings[:validation])
              option_value = New::Task.validate_option(option_name, option_settings, option_value)
            rescue
              option_value = nil
            end
          end

        # collect non array/hash option type value
        else
          option_value = nil
          until option_value
            A.sk '', :newline => false, :preset => :prompt do |response|
              option_value = New::Task.validate_option(option_name, option_settings, response) rescue nil
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

    # Success Message
    S.ay "A `#{'Newfile'.green}` was successfully created for your project `#{name.to_s.green}`"
    S.ay 'Open the file to verify the values are correct, and make any neccessary modifications.'
    S.ay "You are now ready to run `#{'new release'.green}` to release your software into the wild!"
    S.ay
  end

  desc 'tasks', 'List all available tasks'
  option :sources, :type => :boolean, :aliases => ['-s'], :default => false, :desc => 'Show/Hide task sources'
  def tasks args = {}
    # merge into default options
    options = {
     :show_source => (@options['sources'] || false),
     :load_newfiles => true,
     :load_sources => true
    }.merge(args)

    New.load_newfiles if options[:load_newfiles]
    if options[:load_sources]
      S.ay
      S.ay 'Fetching sources...', :header
      S.ay "Use the #{'green'.green} value for defining task sources in your Newfile", :indent => 2 if options[:show_source]
      S.ay
      New::Source.load_sources
    end

    New::Source.sources.each do |source_name, source|
      # determine the widest task & add some padding
      longest_task_length = source.tasks.keys.map(&:length).max

      S.ay source_name.to_s, :indent => 2, :newline => false, :style => :underline
      S.ay source.path, :highlight_value

      source.tasks.each do |task_name, task|
        if options[:show_source]
          padding = longest_task_length + source_name.to_s.length + 2
          S.ay "#{source_name}##{task_name}", :preset => :header, :newline => false, :indent => 2, :padding => padding, :justify => :ljust
        else
          padding = longest_task_length + 2
          S.ay task_name.to_s, :preset => :header, :newline => false, :indent => 2, :padding => padding, :justify => :ljust
        end
        S.ay task.description, :indent => 2
      end

      S.ay
    end
  end

  desc 'release', 'Release a new version of your project'
  option :verbose, :type => :boolean, :aliases => ['-v'], :default => false, :desc => 'Verbose mode'
  option :skip, :type => :array, :aliases => ['-s'], :default => [], :desc => 'Tasks to skip for this release'
  def release
    New.set_verbose if @options['verbose']
    New.set_cli
    New.load_newfiles

    # request the version to bump
    S.ay
    S.ay 'Releasing a new version of: ', :highlight_key
    S.ay New.new_object[:name], :highlight_value
    S.ay 'What do you want to bump: ', :highlight_key
    S.ay "[#{'Mmp'.green}] (#{'M'.green}ajor / #{'m'.green}inor / #{'p'.green}atch)", :preset => :highlight_value, :color => :white
    version = Semantic::Version.new New.new_object[:version]
    version_bump_part = nil
    until version_bump_part
      S.ay 'Current Version:', :highlight_key
      A.sk version.to_s, :highlight_value do |response|
        version_bump_part = case response
        when 'M'
          version.major += 1
          version.minor = 0
          version.patch = 0
        when 'm'
          version.minor += 1
          version.patch = 0
        when 'p'
          version.patch += 1
        else
          S.ay 'You must choose from [Mmp]', :error
          nil
        end
      end
    end
    S.ay 'New Version: ', :highlight_key
    S.ay version.to_s, :highlight_value
    S.ay

    # collect a list of changes in this version
    changelog = get_changelog_from_user
    S.ay

    # show tasks
    S.ay "#{'Running Tasks:'.green} (in order)"
    skip_tasks = @options['skip'].map(&:to_sym)
    New.new_object[:tasks].keys.each do |task|
      if skip_tasks.include?(task)
        S.ay "#{task.to_s} (skipped)", :preset => :fine_print, :indent => 4
      else
        S.ay task.to_s, :indent => 2
      end
    end
    S.ay

    New.new version.to_s, changelog, @options['skip']
  end

  desc 'version', 'Show the current version'
  def version
    New.load_newfiles
    S.ay New.new_object[:name], :preset => :highlight_key, :padding => 0, :indent => 0
    S.ay New.new_object[:version], :highlight_value
  end

  desc 'test', 'Run task tests from sources'
  option :watch, :type => :boolean, :aliases => ['-w'], :desc => 'Watch local tasks for changes and run tests'
  option :source, :type => :string, :aliases => ['-s'], :desc => 'Source name'
  option :task, :type => :string, :aliases => ['-t'], :desc => 'Task name'
  def test
    spec_paths = []
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

    # collect specs to run/watch
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
          spec_paths << spec_path
        end
      end
    end

    # run tests
    if !spec_paths.empty?
      # S.ay "Running tests for `#{task_name}` task in `#{source_name}` source...", :warn
      Kernel::system "bundle exec rspec #{spec_paths.join(' ')}"
    end

    # watch tests
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
    def get_changelog_from_user
      S.ay 'Lets add some items to the changelog', :header
      S.ay 'Add multiple entries by pressing ENTER after each one', :instruction
      S.ay 'Enter an empty value to finish', :instruction

      user_changelog = []
      user_response = nil

      # add entries to the changelog until an empty string is entered
      until user_response == '' && !user_changelog.empty?
        A.sk user_changelog.compact.join("\n"), :prompt do |response|
          if response.empty?
            user_response = ''
            next
          end

          user_changelog << user_response = response
        end
      end

      user_changelog
    end

    def get_array_from_user validation = String
      # start to build the array of user values
      user_array = []

      # convert array to hash of Strings
      if validation.is_a? Array
        validation = array_to_hash validation
      end

      if validation.is_a? Hash
        S.ay 'We need to collect a list of complex objects', :header

        user_response = nil
        until user_response == 'n'
          S.ay "#{user_array.length} objects created: ", :indent => 2, :newline => false
          S.ay user_array.join(', '), :highlight_value
          A.sk 'Press ENTER to create another object.  Enter `n` to stop.', :prompt do |response|
            if response == 'n'
              user_response = 'n'
              next
            end

            user_response = get_hash_from_user(validation, false)
            user_array << user_response
          end
        end

      else
        S.ay "We need to collect a list of #{validation}s", :header
        S.ay 'Add multiple values by pressing ENTER after each one', :instruction
        S.ay 'Enter an empty value to finish', :instruction

        # add to the array until an empty string is entered
        user_response = nil
        until user_response == ''
          A.sk user_array.compact.join(', '), :prompt do |response|

            # if the option is valid, pass through the empty string to end entering values
            if response.empty?
              user_response = ''
              next
            end

            user_response = New::Task.validate_class(response, validation) rescue nil
            user_array << user_response
          end
        end
      end

      return user_array.compact
    end

    def get_hash_from_user validation = {}, allow_custom_keys = true
      # start to build the hash of user values
      user_hash = {}

      # convert array to hash of Strings
      if validation.is_a? Array
        validation = array_to_hash validation
      end

      # get user values for required validation keys
      validation.each do |key, klass|
        S.ay 'We need to collect some required values', :header

        user_response = nil
        until user_response

          # do not allow nested arrays/hashes
          # these should be declared as their own option
          if klass == Array || klass == Hash
            S.ay 'Hash options cannot have nested Arrays or Hashes. They should be declared as their own option.', :error
            exit
          end

          A.sk "Enter a VALUE for `#{key}`", :prompt do |response|
            # make sure validation keys have a value
            if response == ''
              user_response = nil
              next
            end

            begin
              user_response = New::Task.validate_class(response, klass)
              user_hash[key] = user_response
              S.ay user_hash
            rescue
              user_response = nil
            end
          end
        end
      end

      if allow_custom_keys
        # Allow users to enter custom keys AND values
        S.ay 'You can add custom keys & values if you want', :header
        S.ay 'Add multiple key/value pairs by pressing ENTER after each one', :instruction
        S.ay 'Enter an empty key to finish', :instruction

        user_key_response = nil
        until user_key_response == ''
          A.sk 'Enter a KEY name', :prompt do |key_response|
            # exit loop if user is done entering info
            if key_response == ''
              user_key_response = ''
              next
            end

            user_value_response = nil
            until user_value_response
              A.sk "Enter a VALUE for `#{key_response}`", :prompt do |value_response|
                # make sure value exists for user created key
                if value_response == ''
                  user_value_response = nil
                  next
                end

                # create key/value pair
                user_hash[key_response.to_sym] = user_value_response = value_response
                S.ay user_hash
              end
            end
          end
        end
      end

      return user_hash
    end

    # convert an array to a hash
    # uses the array elements as hash keys, and sets the value to String
    # @param array [Array] any array
    # @return [Hash]
    #
    def array_to_hash array
      array_hash = {}
      array.each do |v|
        array_hash[v.to_sym] = String
      end

      return array_hash
    end
  end

  default_task :release
end
