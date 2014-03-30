# coding: utf-8
Gem::Specification.new do |s|
  s.author = 'Ryan Brewster'
  s.bindir = 'bin'
  s.date = '2014-03-29'
  s.description = 'With custom templates and tasks, quickly create a new project and release it to the world.'
  s.email = 'brewster1134@gmail.com'
  s.executables = ["new"]
  s.files = ["Gemfile", "Gemfile.lock", "Guardfile", "LICENSE.txt", "README.md", "bin/new", "lib/new.rb", "lib/new/cli.rb", "lib/new/core.rb", "lib/new/dsl.rb", "lib/new/interpolate.rb", "lib/new/project.rb", "lib/new/task.rb", "lib/new/template.rb", "lib/new/version.rb", "spec/fixtures/custom/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/custom/templates/custom_bar_template/custom_bar.txt", "spec/fixtures/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/tasks/foo_task/Gemfile", "spec/fixtures/tasks/foo_task/foo_task.rb", "spec/fixtures/templates/foo_template/[FOO.BAR].txt.erb", "spec/fixtures/templates/foo_template/nested_[FOO.BAR]/foo.txt.erb", "spec/lib/new/cli_spec.rb", "spec/lib/new/interpolate_spec.rb", "spec/lib/new/project_spec.rb", "spec/lib/new/task_spec.rb", "spec/lib/new/template_spec.rb", "spec/lib/new/version_spec.rb", "spec/lib/new_spec.rb", "spec/spec_helper.rb", "tasks/gem/README.md", "tasks/gem/gem.rb", "tasks/gem/gem_spec.rb", "templates/js/Gemfile", "templates/js/Guardfile", "templates/js/LICENSE-MIT.erb", "templates/js/README.md.erb", "templates/js/demo/index.html.erb", "templates/js/lib/README.md", "templates/js/spec/[PROJECT_NAME].spec.js.coffee.erb", "templates/js/spec/index.html.erb", "templates/js/spec/spec_helper.js.coffee", "templates/js/spec/vendor/chai.js", "templates/js/spec/vendor/sinon-chai.js", "templates/js/spec/vendor/sinon.js", "templates/js/src/README.md", "templates/js/src/[PROJECT_NAME].js.coffee.erb", "templates/js/testem.yml", ".gitignore", ".new", ".rspec", "spec/fixtures/custom/.new", "spec/fixtures/custom/templates/custom_bar_template/.new", "spec/fixtures/project/.new", "spec/fixtures/project/.new_cli_release_spec", "spec/fixtures/templates/custom_bar_template/.gitkeep", "spec/fixtures/templates/foo_template/.new", "tasks/gem/.gemspec.erb", "templates/js/.gitignore", "templates/js/.new"]
  s.homepage = 'https://github.com/brewster1134/new'
  s.license = 'MIT'
  s.name = 'new'
  s.summary = 'A Quick & Custom Project Creation & Release Tool'
  s.test_files = ["spec/fixtures/custom/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/tasks/foo_task/foo_task.rb", "spec/lib/new/cli_spec.rb", "spec/lib/new/interpolate_spec.rb", "spec/lib/new/project_spec.rb", "spec/lib/new/task_spec.rb", "spec/lib/new/template_spec.rb", "spec/lib/new/version_spec.rb", "spec/lib/new_spec.rb", "spec/spec_helper.rb"]
  s.version = '0.0.12'
  s.add_runtime_dependency 'activesupport', '~> 4.0'
  s.add_runtime_dependency 'colorize', '>= 0'
  s.add_runtime_dependency 'rake', '>= 0'
  s.add_runtime_dependency 'recursive-open-struct', '>= 0'
  s.add_runtime_dependency 'semantic', '>= 0'
  s.add_runtime_dependency 'thor', '>= 0'
  s.add_development_dependency 'guard', '>= 0'
  s.add_development_dependency 'guard-bundler', '>= 0'
  s.add_development_dependency 'guard-rspec', '>= 0'
  s.add_development_dependency 'rspec', '>= 0'
  s.add_development_dependency 'terminal-notifier-guard', '>= 0'
end
