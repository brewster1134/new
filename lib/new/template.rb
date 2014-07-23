require 'yaml'

class New::Template
  include New::Interpolate

  # The foundation for new template configuration files
  #
  CUSTOM_CONFIG_TEMPLATE = {
    license: '[LICENSE]',
    version: '0.0.0',
    developer: {
      name: '[NAME]',
      email: '[EMAIL]'
    }
  }

  def initialize type, name
    @type = type
    @name = name

    interpolate template_dir, options
  end

  # Create the options object
  #
  def options
    # merge options together
    CUSTOM_CONFIG_TEMPLATE.clone
      .deep_merge!(template_config)
      .deep_merge!(New.custom_config)
      .deep_merge!({
        project_name: @name,
        project_filename: to_filename(@name),
        type: @type.to_s
      })
  end

private

  # Get the template directory to copy from
  #
  def template_dir
    @template_dir ||= if New.custom_templates.include? @type
      @custom = true
      File.join(New::CUSTOM_DIR, New::TEMPLATES_DIR_NAME, @type.to_s)
    else
      File.join(New::DEFAULT_DIR, New::TEMPLATES_DIR_NAME, @type.to_s)
    end
  end

  # Get the configuration for the template
  #
  def template_config
    return @template_config if @template_config

    @template_config = YAML.load(File.open(File.join(template_dir, New::CONFIG_FILE))).deep_symbolize_keys! rescue {}
    if @custom
      @template_config.merge!({
        custom: true
      })
    end

    @template_config
  end
end
