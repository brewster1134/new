class New::TaskTask < New::Task
  @@description = 'Spec Task Description'
  @@options = {
    :required => {
      :description => 'description of required',
      :required => true
    },
    :default => {
      :description => 'description of default',
      :default => 'default value'
    },
    :required_default => {
      :description => 'description of required_default',
      :required => true,
      :default => 'required default value'
    },
    :type_string => {
      :description => 'description of type_string',
      :type => String,
      :validation => /foo_.+_bar/
    },
    :type_symbol => {
      :description => 'description of type_symbol',
      :type => Symbol,
      :validation => /foo_.+_bar/
    },
    :type_boolean => {
      :description => 'description of type_boolean',
      :type => Boolean
    },
    :type_integer => {
      :description => 'description of type_integer',
      :type => Integer,
      :validation => (1..10)
    },
    :type_float => {
      :description => 'description of type_float',
      :type => Float,
      :validation => (1.5..10.5)
    },
    :type_array => {
      :description => 'description of type_array',
      :type => Array,
      :validation => Symbol,
      :required => true
    },
    :type_hash_array => {
      :description => 'description of type_hash_array',
      :type => Hash,
      :validation => [:foo]
    },
    :type_hash_hash => {
      :description => 'description of type_hash_hash',
      :type => Hash,
      :validation => {
        :foo => Integer
      }
    }
  }

  # options must be set to an instance var `@options`
  # otherwise `super` must be called
  def verify options
    super
    @verified = true
  end

  def run
    @ran = true
  end
end
