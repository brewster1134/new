class New::Task::FooTask < New::Task
  OPTIONS = {
    foo: 'default',
    default: true
  }
  def run; end
end
