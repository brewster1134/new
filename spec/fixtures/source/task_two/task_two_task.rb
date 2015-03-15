class New::TaskTwoTask < New::Task
  @@description = 'Spec Task Two Description'
  @@options = {}

  # do not include verify method
  # we use this fixture to test the verify method on the parent class
  # def verify; end

  def run
    @ran = true
  end
end
