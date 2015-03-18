class New::Task
  extend New::Validation
  SILENCE = '>> /dev/null 2>&1'

  #
  # CLASS METHODS
  #
  class << self
    # global tasks for task class with a getter
    @@tasks = {}
    def tasks; @@tasks; end

    # derive a task name from a task path
    # @param task_path [String] full path to a task ruby file
    #
    def get_task_name task_path
      task_path.match(/([^\/]*)_task\.rb$/)[1].to_sym
    end

  private

    # when custom task is required, add the class to the global hash to initialize later
    #
    def inherited subclass
      # get task details from path
      path = caller.first.match(/(^.*_task\.rb).*$/)[1]
      name = get_task_name path

      # add subclass to global object for easier lookup
      @@tasks[name] = subclass.new name, path
    end
  end


  #
  # INSTANCE METHODS
  #
  attr_accessor :source, :options
  attr_reader :name, :path
  attr_reader :options

  # getters/setters for task meta data stored temporarily on a class var
  def description
    @description ||= self.class.class_variable_get :@@description rescue ''
  end

  def class_options
    @class_options ||= self.class.class_variable_get :@@options rescue {}
  end

  def options
    @options.dup
  end

  # task to check that outside dependencies are met before we run the tasks
  #
  def verify
  end

  # validate all options
  #
  def validate
    class_options.keys.each do |option_name|
      option_value = @options[:task_options][option_name]
      new_option_value = validate_option(option_name, option_value)

      # set the new validated value
      @options[:task_options][option_name] = new_option_value
    end
  end

  # validate a task option using a task and its associated options
  #
  # @param option_name [Symbol] name of supported option name for given task
  # @param value [String] typically a user-input value
  # @return a valid option value depending on the type/validation rules
  #         if no valid value can be made, return nil
  def validate_option option_name, value
    # validate supported options
    unless option = class_options[option_name]
      raise_error option_name, 'is not a supported option'
    end

    # validate required option or set default
    if !value || value.empty?
      # if the option is required, raise an error
      if option[:required]
        raise_error option_name, 'is a required option'

      # otherwise set the default
      elsif option[:default]
        value = option[:default]
      end
    end

    # set default
    type = option[:type] || String

    # validate and convert value to specified type
    value = New::Task.validate_class value, type

    # validate with custom validation
    if validation = option[:validation]
      value = case

      when type == String
        validate_regexp option_name, value, validation

      when type == Symbol
        validate_regexp option_name, value, validation

      when type == Integer
        validate_range option_name, value, validation

      when type == Float
        validate_range option_name, value, validation

      when type == Array
        validation = validation || String

        unless validation == String || validation == Symbol || validation == Boolean || validation == Integer || validation == Float
          raise_error option_name, "validation must be a [String|Symbol|Boolean|Integer|Float]"
        end

        # validate each element in array with the validation class type
        value.map! do |v|
          New::Task.validate_class v, validation
        end

        return value

      when type == Hash
        unless validation.is_a?(Array) || validation.is_a?(Hash)
          raise_error option_name, "validation must be an Array or Hash of required keys (Check the New docs for the requirements)"
        end

        # make sure value contains all the required validation keys
        value_keys = (value.is_a?(Array) ? value : value.keys).map(&:to_sym)
        validation_keys = (validation.is_a?(Array) ? validation : validation.keys).map(&:to_sym)
        unless (validation_keys & value_keys) == validation_keys
          raise_error option_name, "must contain all the following keys: #{validation_keys.join(', ')}"
        end

        # make sure values are of the provided class type
        if validation.is_a? Hash
          validation.each do |key, klass|
            value[key] = New::Task.validate_class value[key], klass
          end
        end

        return value
      else
        return value
      end
    end

    return value
  end

private

  def initialize name, path
    @name = name
    @path = path
  end

  # check that a value matches a regexp
  #
  # @param option_name [Symbol] the task option name
  # @param value [String] the passed user value
  # @param regexp [Regexp] a regular expression object. defaults to `.*`
  #
  def validate_regexp option_name, value, regexp
    return value unless regexp

    # validate validation
    raise_error option_name, 'validation must be a `Regexp`' unless regexp.is_a? Regexp

    # check if the value still exists after comparing to the regexp
    if value[regexp]
      return value
    else
      raise_error option_name, "`#{value}` did not match the regexp `#{regexp.to_s.sub('(?-mix:', '').sub(/\)$/, '')}`."
    end
  end

  def validate_range option_name, value, range
    # if no range is set... any value is valid
    return value unless range

    # validate validation
    raise_error option_name, 'validation must be a `Range`' unless range.is_a? Range

    if range.include? value
      return value
    else
      raise_error option_name, "`#{value}` must be within `#{range.min}` and `#{range.max}`"
    end
  end

  def raise_error option_name, message
    S.ay "#{@name.to_s.upcase}: ", :preset => :fail, :newline => false, :style => :bold
    S.ay option_name.to_s, :preset => :fail, :newline => false, :style => [:bold, :underline]
    S.ay message.to_s, :preset => :fail, :indent => 1
    raise
  end
end
