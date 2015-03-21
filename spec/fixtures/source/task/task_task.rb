class New::TaskTask < New::Task
  @@description = 'Spec Task Description'
  @@options = {
    :test => {
      :description => 'description of test option',
      :type => Array,
      :validation => {
        :foo => Integer
      }
    }
  }

  # options must be set to an instance var `@options`
  # otherwise `super` must be called
  def verify
    @verified = true
  end

  def run
    @ran = true
  end
end
