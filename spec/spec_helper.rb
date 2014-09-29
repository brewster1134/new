$: << File.expand_path('../../lib', __FILE__)
require 'new'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.order = :random

  config.before do
    stub_const 'New::GLOBAL_CONFIG_FILE', root('spec', 'fixtures', 'home_folder_new')
  end
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
