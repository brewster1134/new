require 'bundler'
require 'rake'
require 'yaml'

class New::Task::Gem < New::Task
  include New::Interpolate
  include New::Version

  GLOB_ATTRIBUTES = [:files, :test_files, :extra_rdoc_files]
  GEMFILE = File.expand_path(File.join(Dir.pwd, 'Gemfile'))
  OPTIONS = {
    gemspec: {
      summary: "A short summary of this gem's description. Displayed in `gem list -d`",
      files: ['**/*','**/.*']
    }
  }

  def run
    @gemspec = options[:gemspec]

    set_version
    validate_files
    render_gemspec_options
    write_gemspec
    write_config
    deploy

    New.say "Version #{project_options[:version].green} of the #{project_options[:project][:name].green} gem successfully published."
  end

private

  def set_version
    # bump version
    bump_version project_options[:version]

    # set new version to config
    project_options[:version] = version.to_s
  end

  # Check that any glob pattern attributes match existing files
  #
  def validate_files
    GLOB_ATTRIBUTES.each do |file_attr|
      next if @gemspec[file_attr].nil?

      files = []
      @gemspec[file_attr].each do |glob|
        matching_files = FileList.new(glob).select{ |f| File.file? f }
        matching_files.delete '.gemspec'

        if matching_files.empty?
          New.say "The pattern `#{glob}` in `tasks.gem.gemspec.#{file_attr}` did not match any files."
          New.say 'Please check your configuration file.'
          exit
        else
          files << matching_files
        end
      end

      @gemspec[file_attr] = files.flatten
    end
  end

  def render_gemspec_options
    array = []

    # set defaults
    @gemspec[:date]    = Date.today.to_s
    @gemspec[:name]    = project_options[:project][:name]
    @gemspec[:version] = project_options[:version]
    @gemspec[:author]  ||= project_options[:developer][:name]
    @gemspec[:email]   ||= project_options[:developer][:email]
    @gemspec[:license] ||= project_options[:license]

    # remove singular attributes if plural attribute is specified
    if @gemspec[:authors]
      @gemspec.delete(:author)
      @gemspec[:authors] = @gemspec[:authors]
    end
    if @gemspec[:licenses]
      @gemspec.delete(:license)
      @gemspec[:licenses] = @gemspec[:licenses]
    end

    @gemspec.sort.each do |k,v|
      val = case v
      when String then "'#{v}'"
      else v
      end

      array << "  s.#{k} = #{val}"
    end

    array += extract_gem_dependencies

    project_options[:gemspec_string] = array.join("\n")
  end

  # Extract dependencies based on the Gemfile to be used in the gemspec
  #
  def extract_gem_dependencies
    b = Bundler::Dsl.new
    b.eval_gemfile(GEMFILE)

    array = []
    runtime = []
    development = []

    # loop through the required gems and find default and development gems
    b.dependencies.each do |g|
      requirements = g.requirements_list.map{ |r| "'#{r}'" }.join(',')
      data = {
        name: g.name,
        requirements: requirements
      }

      groups = g.groups
      runtime <<  data if groups.include? :default
      development <<  data if groups.include? :development
    end

    # create .gemspec friendly string of requirements
    runtime.each do |r|
      array << "  s.add_runtime_dependency '#{r[:name]}', #{r[:requirements]}"
    end
    development.each do |r|
      array << "  s.add_development_dependency '#{r[:name]}', #{r[:requirements]}"
    end

    return array
  end

  def write_gemspec
    New.say 'Updating `.gemspec` file...', type: :success

    # process gemspec
    interpolate File.join(File.dirname(__FILE__), '.gemspec.erb'), project_options

    # copy it to the project
    FileUtils.cp File.join(@dest_path, '.gemspec'), Dir.pwd

    # cleanup the tmp
    FileUtils.rm_rf @dest_path
  end

  def write_config
    New.say 'Updating `.new` file...', type: :success

    writeable_options = project_options.dup
    writeable_options.delete(:gemspec_string)
    GLOB_ATTRIBUTES.each{ |a| writeable_options.delete(a) }

    File.open(New::CONFIG_FILE, 'w+') do |f|
      f.write writeable_options.deep_stringify_keys.to_yaml
    end
  end

  def deploy
    New.say 'Pushing new gem version to rubygems...', type: :success
    New.say '                ...This may take a bit', type: :warn

    `gem update --system`
    `gem build .gemspec`
    `gem push #{@gemspec[:name]}-#{@gemspec[:version]}.gem`
    FileUtils.rm_rf "#{@gemspec[:name]}-#{@gemspec[:version]}.gem"

    New.say "#{@gemspec[:name]}-#{@gemspec[:version]} released".green
  end
end
