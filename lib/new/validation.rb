module New::Validation
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
      S.ay "`#{value}` cannot be converted to #{klass}", :fail
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
      S.ay "`#{value}` could not be converted into a proper symbol (Check the New docs for the requirements)", :fail
      raise
    end
  end

  def validate_boolean value
    case value
    when 'true' then true
    when 'false' then false
    else
      S.ay "`#{value}` must be either `true` or `false`", :fail
      raise
    end
  end
end
