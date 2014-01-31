require 'erb'

module New::Interpolate
  # regex to match capital underscored template options names ie [PROJECT_NAME]
  FILENAME_RENAME_MATCH = /\[([A-Z_.]+)\]/

  # Convienance method for processing everything
  #
  def interpolate root_path, options
    create_dot_options options
    process_paths root_path
    process_files root_path
  end

  # Convert options to OpenStruct so we can use dot notation in the templates
  #
  def create_dot_options options
    @dot_options = RecursiveOpenStruct.new(options)
  end

  # Collect files with an .erb extension to interpolate
  #
  def process_files root_path
    Dir.glob(File.join(root_path, '**/*.erb'), File::FNM_DOTMATCH).each do |file|
      process_file file
    end
  end

  # Collect files with a matching value to interpolate
  #
  def process_paths root_path
    get_path = -> type do
      Dir.glob(File.join(root_path, '**/*')).select do |e|
        File.send("#{type}?".to_sym, e) && e =~ FILENAME_RENAME_MATCH
      end
    end

    # rename directories first
    get_path[:directory].each{ |dir| process_path dir }
    get_path[:file].each{ |file| process_path file }
  end

  # Allow templates to call option values directly
  #
  def method_missing method
    @dot_options.send(method.to_sym) || super
  end

  def options; @dot_options; end

private

  # Interpolate erb template data
  #
  def process_file file
    # Process the erb file
    processed_file = ERB.new(File.read(file)).result(binding)

    # Overwrite the original file with the processed file
    File.open file, 'w' do |f|
      f.write processed_file
    end

    # Remove the .erb from the file name
    File.rename file, file.chomp('.erb')
  end


  # Interpolate filenames with template options
  #
  def process_path path
    new_path = path.gsub FILENAME_RENAME_MATCH do
      # Extract interpolated values into symbols
      methods = $1.downcase.split('.').map(&:to_sym)

      # Call each method on options
      methods.inject(@dot_options){ |options, method| options.send(method.to_sym) }
    end

    if File.file? path
      File.rename path, new_path
    else
      FileUtils.mv path, new_path
    end
  end
end
