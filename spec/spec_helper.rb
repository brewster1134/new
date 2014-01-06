$: << File.expand_path('../../lib', __FILE__)
$: << File.expand_path('../fixtures', __FILE__)
require 'new'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random
  config.before do
    New.stub(:say)
  end
end

def root *paths
  paths.unshift(File.expand_path('../../', __FILE__)).compact.join '/'
end
