# coding: utf-8
Gem::Specification.new do |s|
  s.executables = ["new"]
  s.bindir = 'bin'
  s.name = 'new'
  s.version = '1.0.1'
  s.date = '2015-03-05'
  s.summary = 'A flexible tool for releasing your code into the wild'
  s.files = ["bin/new", "lib/new/cli.rb", "lib/new/source.rb", "lib/new/task.rb", "lib/new/validation.rb", "lib/new.rb", "Gemfile"]
  s.authors = ["Ryan Brewster"]
  s.add_runtime_dependency 'bundler', '~> 1.7'
  s.add_runtime_dependency 'cli_miami', '~> 0.0'
  s.add_runtime_dependency 'listen', '~> 2.8'
  s.add_runtime_dependency 'semantic', '~> 1.4'
  s.add_runtime_dependency 'sourcerer_', '~> 0.0'
  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_development_dependency 'coveralls', '~> 0.7'
  s.add_development_dependency 'guard', '~> 2.6'
  s.add_development_dependency 'guard-bundler', '~> 2.1'
  s.add_development_dependency 'guard-rspec', '~> 4.3'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'terminal-notifier-guard', '~> 1.5'
end