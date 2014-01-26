# More info at https://github.com/guard/guard#readme

notification :terminal_notifier, subtitle: 'ruby.gems.new'

guard :bundler do
  watch('Gemfile')
end

guard :rspec, all_after_pass: true, all_on_start: true, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
  watch('.rspec')               { 'spec' }
end
