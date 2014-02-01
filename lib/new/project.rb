class New::Project
  include New::Interpolate

  # Create all variables and run new project creation methods
  #
  def initialize template, name
    @project_dir = File.join(Dir.pwd, name.to_s) # the newly created project directory
    @template = New::Template.new template, name

    copy_template
    create_config_file
  end

private

  # Create the new project by copying the template directory
  #
  def copy_template
    FileUtils.cp_r @template.dir, @project_dir

    # cleanup tmp
    FileUtils.rm_rf @template.dir
  end

  # Create the .new configuration file in the new project
  #
  def create_config_file
    new_config = File.join(@project_dir, New::CONFIG_FILE)
    File.open new_config, 'w' do |f|
      yaml_options = @template.options.deep_dup.deep_stringify_keys!.to_yaml
      f.write(yaml_options)
    end
  end
end
