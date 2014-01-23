class New::Task::FooTask < New::Task
  DEFAULT_OPTIONS = {
    foo: 'default',
    default: true
  }

  def initialize options
  end
end
