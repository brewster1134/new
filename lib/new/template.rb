class New::Template
  include New::Interpolate

  def initialize template_name, project
    @template_name = template_name
    @template_dir = find_template
    @project = project
    @options = get_options

    interpolate @template_dir, @options
  end

  def options; @options; end

private

  # Create the options object
  #
  def get_options
    global_options = New.global_config
    global_template_options = global_options.delete(:templates)[@template_name] || {}

    global_options
      .deep_merge({
        template: template_options.deep_merge(global_template_options),
        project: {
          name: @project.name,
          filename: @project.filename
        }
      })
    .deep_symbolize_keys
  end

  # Get the template directory to copy from
  # TODO: source all templates
  #
  def find_template
    ''
  end

  # Get the configuration for the template
  #
  def template_options
    file_options = YAML.load(File.open(File.join(@template_dir, New::CONFIG_FILE))) rescue {}
    file_options.merge({
      name: @template_name.to_s
    })
  end
end
