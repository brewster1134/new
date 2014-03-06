require 'erb'
require 'recursive-open-struct'

module New::Interpolate
  # regex to match capital underscored template options names ie [PROJECT_NAME]
  FILENAME_RENAME_MATCH = /\[([A-Z_.]+)\]/

  # Convienance method for processing everything
  #
  def interpolate src_path, options
    @src_path = src_path
    @options = options

    copy_to_tmp
    process_paths
    process_files
  end

  def dir
    File.file?(@src_path) ? @dest_path : File.join(@dest_path, File.basename(@src_path))
  end

  # Convert options to OpenStruct so we can use dot notation in the templates
  #
  def dot_options
    @dot_options ||= RecursiveOpenStruct.new(@options)
  end

private

  # Allow templates to call option values directly
  #
  def method_missing method
    dot_options.send(method.to_sym) || super
  end

  def copy_to_tmp
    # Create a unique temporary path to store the processed files
    @dest_path = Dir.mktmpdir

    # Copy to tmp
    FileUtils.cp_r @src_path, @dest_path
  end

  # Collect files with a matching value to interpolate
  #
  def process_paths
    get_path = -> type do
      Dir.glob(File.join(@dest_path, '**/*')).select do |e|
        File.send("#{type}?".to_sym, e) && e =~ FILENAME_RENAME_MATCH
      end
    end

    # rename directories first
    get_path[:directory].each{ |dir| process_path dir }
    get_path[:file].each{ |file| process_path file }
  end

  # Interpolate filenames with template options
  #
  def process_path path
    new_path = path.gsub FILENAME_RENAME_MATCH do
      # Extract interpolated values into symbols
      methods = $1.downcase.split('.').map(&:to_sym)

      # Call each method on options
      methods.inject(dot_options){ |options, method| options.send(method.to_sym) }
    end

    if File.file? path
      File.rename path, new_path
    else
      FileUtils.mv path, new_path
    end
  end

  # Collect files with an .erb extension to interpolate
  #
  def process_files
    Dir.glob(File.join(@dest_path, '**/*.erb'), File::FNM_DOTMATCH).each do |file|
      process_file file
    end
  end

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
end
