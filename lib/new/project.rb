class New::Project
  include New::Version

  # Create all variables and run new project creation methods
  #
  def initialize template, name
    @project_dir = File.join(Dir.pwd, name.to_s) # the newly created project directory
    @template = New::Template.new template, self

    copy_template
    create_config_file
  end

private

  # Create the new project by copying the template directory
  #
  def copy_template
    FileUtils.cp_r @template.dir, @project_dir
  end

  # Create the .new configuration file in the new project
  #
  def create_config_file
    new_config = File.join(@project_dir, New::CONFIG_FILE)

    global_options = New.global_options
    template_options = @template.options.to_hash

    File.open new_config, 'w' do |f|
      f.write global_options.merge(template_options).deep_stringify_keys!.to_yaml
    end
  end
end
