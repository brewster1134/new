module New::Validation
  # validate a task option using a task and its associated options
  #
  # @param option_name  [String]  name of an option
  # @param option       [Hash]    formatted option object
  # @param value        [String]  typically a user-input value
  # @return a valid option value depending on the type/validation rules
  #         if no valid value can be made, return nil
  def validate_option option_name, option, value
    # validate required option or set default
    if !value || value.empty?
      # if the option is required, raise an error
      if option[:required]
        raise_validation_error option_name, 'is a required option'

      # otherwise set the default
      else
        value = option[:default]
      end
    end

    # set default type
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
        # set default
        validation = validation || String

        # If validation is an array convert it to a hash of String
        if validation.is_a? Array
          validation_hash = {}
          validation.each do |v|
            validation_hash[v] = String
          end
          validation = validation_hash
        end

        # if validation is a hash, make sure all values exist for required keys
        if validation.is_a? Hash
          value.each do |v|
            if validation.keys != v.keys
              raise_validation_error option_name, "validation for an Array must contain values for `#{validation.keys.join(', ')}`"
            end
          end
        else
          unless validation == String || validation == Symbol || validation == Boolean || validation == Integer || validation == Float
            raise_validation_error option_name, "validation for an Array must be a [String|Symbol|Boolean|Integer|Float]"
          end
        end

        # validate each element in array with the validation class type
        value.map! do |v|
          New::Task.validate_class v, validation
        end

        return value

      when type == Hash
        unless validation.is_a?(Array) || validation.is_a?(Hash)
          raise_validation_error option_name, "validation must be an Array or Hash of required keys (Check the New docs for the requirements)"
        end

        # make sure value contains all the required validation keys
        value_keys = (value.is_a?(Array) ? value : value.keys).map(&:to_sym)
        validation_keys = (validation.is_a?(Array) ? validation : validation.keys).map(&:to_sym)
        unless (validation_keys & value_keys) == validation_keys
          raise_validation_error option_name, "must contain all the following keys: #{validation_keys.join(', ')}"
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

  def validate_class value, klass
    begin
      case
      when klass == String  then String(value)
      when klass == Symbol  then validate_symbol value
      when klass == Boolean then validate_boolean value
      when klass == Integer then Float(value).to_i
      when klass == Float   then Float(value)
      when klass == Array   then value.delete_if{ |v| v == nil || v == '' }
      when klass == Hash    then value.delete_if{ |k, v| v == nil || v == '' || v == [] }
      else value
      end
    rescue
      S.ay "`#{value}` cannot be converted to #{klass}", :error
      raise
    end
  end

private

  # convert back to string
  # convert to lowercase
  # replace non-alpha characters to underscores
  # convert consecutive underscores (__) to a single underscore (_)
  # remove leading underscore
  # remove trailing underscore
  #
  def validate_symbol value
    begin
      symbol_name = String(value).downcase.gsub(/[^a-z_]/, '_').gsub(/_+/, '_').sub(/^_/, '').sub(/_$/, '').to_sym
      raise if symbol_name.empty?
      symbol_name
    rescue
      S.ay "`#{value}` could not be converted into a proper symbol (Check the New docs for rules)", :error
      raise
    end
  end

  def validate_boolean value
    case value.downcase
    when 'true', 'yes' then true
    when 'false', 'no' then false
    else
      S.ay "`#{value}` must be either `true/yes` or `false/no`", :error
      raise
    end
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
    raise_validation_error option_name, 'validation must be a `Regexp`' unless regexp.is_a? Regexp

    # check if the value still exists after comparing to the regexp
    if value[regexp]
      return value
    else
      raise_validation_error option_name, "`#{value}` did not match the regexp `#{regexp.to_s.sub('(?-mix:', '').sub(/\)$/, '')}`."
    end
  end

  def validate_range option_name, value, range
    # if no range is set... any value is valid
    return value unless range

    # validate validation
    raise_validation_error option_name, 'validation must be a `Range`' unless range.is_a? Range

    if range.include? value
      return value
    else
      raise_validation_error option_name, "`#{value}` must be within `#{range.min}` and `#{range.max}`"
    end
  end

  def raise_validation_error option_name, message
    S.ay "#{@name.to_s.upcase}: #{option_name}: #{message.white}", :preset => :error
    raise
  end
end
