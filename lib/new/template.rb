# Templates are responsible for prepping a template and storing it in a tmp dir
#
class New::Template
  include New::Interpolate

  # The foundation for new template configuration files
  #
  CUSTOM_CONFIG_TEMPLATE = {
    license: '[LICENSE]',
    templates: {},
    tasks: {
      github: {
        username: '[USERNAME]'
      }
    },
    developer: {
      name: '[NAME]',
      email: '[EMAIL]'
    }
  }

  def initialize type, name
    @type = type
    @name = name
    @source_template_dir = get_template_dir

    # Interpolate methods
    create_dot_options options
    copy_template
    process_files @dest_template_dir
    process_paths @dest_template_dir
  end

  def dir; @dest_template_dir; end

private

  # Get the template directory to copy from
  #
  def get_template_dir
    if New.custom_templates.include? @type
      @custom = true
      File.join(New::CUSTOM_DIR, New::TEMPLATES_DIR_NAME, @type.to_s)
    else
      File.join(New::DEFAULT_DIR, New::TEMPLATES_DIR_NAME, @type.to_s)
    end
  end

  # Create the options object
  #
  def options
    template_config = get_template_config
    custom_config = New.custom_config

    # merge options together
    CUSTOM_CONFIG_TEMPLATE.clone
      .deep_merge!(template_config)
      .deep_merge!(custom_config)
      .deep_merge!({
        type: @type.to_s,
        project_name: @name
      })
  end

  # Get the configuration for the template
  #
  def get_template_config
    template_config = YAML.load(File.open(File.join(@source_template_dir, New::CONFIG_FILE))).deep_symbolize_keys! rescue {}
    if @custom
      template_config.merge!({
        custom: true
      })
    end

    template_config
  end

  # Copy template to tmp dir for processing
  #
  def copy_template
    tmp_template_dir = File.join(New::TEMP_DIR, @type.to_s)

    # delete existing template & copy a new one
    FileUtils.rm_rf tmp_template_dir
    FileUtils.cp_r @source_template_dir, New::TEMP_DIR

    @dest_template_dir = tmp_template_dir
  end
end
