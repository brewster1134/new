source 'https://rubygems.org'

gem 'bundler', '>= 1.2.0'

group :development do
  gem 'guard'
  gem 'guard-coffeescript'
  gem 'guard-sass'
end

# Platform specific gems (set `require: false`)
group :development do
  gem 'rb-fsevent', :require => false
  gem 'growl', require: false
  gem 'terminal-notifier-guard', require: false
end

# OS X
if RUBY_PLATFORM.downcase =~ /darwin/
  require 'rb-fsevent'

  # >= 10.8 Mountain Lion
  if RUBY_PLATFORM.downcase =~ /darwin12/
    require 'terminal-notifier-guard'

  # <= 10.7 Lion
  else
    require 'growl'
  end
end
