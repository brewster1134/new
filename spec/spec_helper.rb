$: << File.expand_path('../../lib', __FILE__)
# $: << File.expand_path('../../tasks', __FILE__)
# $: << File.expand_path('../fixtures', __FILE__)
require 'new'
# $: << File.expand_path('tasks', New::CUSTOM_DIR)

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.order = :random

  config.before do
    stub_const 'New::GLOBAL_CONFIG_FILE', root('spec', 'fixtures', 'home_folder_new')
  #   allow(New).to receive :say
  #   stub_const 'New::DEFAULT_DIR', root('spec', 'fixtures')
  #   stub_const 'New::CUSTOM_DIR', root('spec', 'fixtures', 'custom')
  end

  # config.before :each do
  #   # Force specs to always lookup new templates and tasks
  #   New.instance_variables.each{ |v| New.instance_variable_set(v, nil) }
  # end
end

# Allow true/false to respond to Boolean class
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

class Object
  def var var, value = nil
    if self.instance_of? Class
      class_var var, value
    else
      instance_var var, value
    end
  end

  def class_var var, value = nil
    if value
      self.send(:class_variable_set, :"@@#{var}", value)
    else
      self.send(:class_variable_get, :"@@#{var}")
    end
  end

  def instance_var var, value = nil
    if value
      self.send(:instance_variable_set, :"@#{var}", value)
    else
      self.send(:instance_variable_get, :"@#{var}")
    end
  end
end

def root *paths
  paths.unshift(File.expand_path('../../', __FILE__)).compact.join '/'
end

# def require_task task
#   require "#{task}/#{task}"
# end

# def new_task task, options = {}
#   task_class = "New::Task::#{task.to_s.classify}".constantize

#   allow_any_instance_of(task_class).to receive(:get_part).and_return(:patch)
#   allow_any_instance_of(task_class).to receive(:run)

#   task_hash = {}
#   task_hash[task] = {}
#   task_options = {
#     tasks: task_hash
#   }.merge(options)

#   task_class.new task_options
# end


