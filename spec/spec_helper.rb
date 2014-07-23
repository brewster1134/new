$: << File.expand_path('../../lib', __FILE__)
require 'new'
$: << File.expand_path('../../tasks', __FILE__)
$: << File.expand_path('../fixtures', __FILE__)
$: << File.expand_path('tasks', New::CUSTOM_DIR)

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random

  config.before do
    allow(New).to receive :say
    stub_const 'New::DEFAULT_DIR', root('spec', 'fixtures')
    stub_const 'New::CUSTOM_DIR', root('spec', 'fixtures', 'custom')
  end

  config.before :each do
    # Force specs to always lookup new templates and tasks
    New.instance_variables.each{ |v| New.instance_variable_set(v, nil) }
  end
end

def root *paths
  paths.unshift(File.expand_path('../../', __FILE__)).compact.join '/'
end

def require_task task
  require "#{task}/#{task}"
end

def new_task task, options = {}
  task_class = "New::Task::#{task.to_s.classify}".constantize

  allow_any_instance_of(task_class).to receive(:get_part).and_return(:patch)
  allow_any_instance_of(task_class).to receive(:run)

  task_hash = {}
  task_hash[task] = {}
  task_options = {
    tasks: task_hash
  }.merge(options)

  task_class.new task_options
end
