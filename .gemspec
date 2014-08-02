# coding: utf-8
Gem::Specification.new do |s|
  s.author = 'Ryan Brewster'
  s.bindir = 'bin'
  s.date = '2014-08-02'
  s.description = 'With custom templates and tasks, quickly create a new project and release it to the world.'
  s.email = 'brewster1134@gmail.com'
  s.executables = ["new"]
  s.files = ["Gemfile", "Gemfile.lock", "Guardfile", "LICENSE.txt", "README.md", "bin/new", "lib/new.rb", "lib/new/cli.rb", "lib/new/core.rb", "lib/new/dsl.rb", "lib/new/interpolate.rb", "lib/new/project.rb", "lib/new/task.rb", "lib/new/template.rb", "lib/new/version.rb", "spec/fixtures/custom/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/custom/templates/custom_bar_template/custom_bar.txt", "spec/fixtures/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/tasks/foo_task/Gemfile", "spec/fixtures/tasks/foo_task/foo_task.rb", "spec/fixtures/templates/foo_template/[FOO.BAR].txt.erb", "spec/fixtures/templates/foo_template/nested_[FOO.BAR]/foo.txt.erb", "spec/lib/new/cli_spec.rb", "spec/lib/new/interpolate_spec.rb", "spec/lib/new/project_spec.rb", "spec/lib/new/task_spec.rb", "spec/lib/new/template_spec.rb", "spec/lib/new/version_spec.rb", "spec/lib/new_spec.rb", "spec/spec_helper.rb", "tasks/gem/README.md", "tasks/gem/gem.rb", "tasks/gem/gem_spec.rb", "templates/js/CHANGELOG.md", "templates/js/Gemfile", "templates/js/Guardfile", "templates/js/LICENSE-MIT.erb", "templates/js/README.md.erb", "templates/js/bower.json.erb", "templates/js/demo/[PROJECT.FILENAME]_demo.coffee", "templates/js/demo/[PROJECT.FILENAME]_demo.sass", "templates/js/demo/index.html.erb", "templates/js/lib/README.md", "templates/js/package.json", "templates/js/spec/[PROJECT.FILENAME]_spec.coffee.erb", "templates/js/spec/[PROJECT.FILENAME]_spec.sass", "templates/js/spec/index.html.erb", "templates/js/src/[PROJECT.FILENAME].coffee.erb", "templates/js/src/[PROJECT.FILENAME].sass", "templates/js/testem.yml", "templates/js/yuyi_menu", ".gitignore", ".new", ".rspec", "spec/fixtures/custom/.new", "spec/fixtures/custom/templates/custom_bar_template/.new", "spec/fixtures/project/.new", "spec/fixtures/project/.new_cli_release_spec", "spec/fixtures/templates/custom_bar_template/.gitkeep", "spec/fixtures/templates/foo_template/.new", "tasks/gem/.gemspec.erb", "templates/js/.bowerrc", "templates/js/.gitignore", "templates/js/.new.erb"]
  s.homepage = 'https://github.com/brewster1134/new'
  s.license = 'MIT'
  s.name = 'new'
  s.summary = 'A Quick & Custom Project Creation & Release Tool'
  s.test_files = ["spec/fixtures/custom/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/tasks/custom_bar_task/custom_bar_task.rb", "spec/fixtures/tasks/foo_task/foo_task.rb", "spec/lib/new/cli_spec.rb", "spec/lib/new/interpolate_spec.rb", "spec/lib/new/project_spec.rb", "spec/lib/new/task_spec.rb", "spec/lib/new/template_spec.rb", "spec/lib/new/version_spec.rb", "spec/lib/new_spec.rb", "spec/spec_helper.rb"]
  s.version = '0.1.1'
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
