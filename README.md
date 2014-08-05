# new
**_NEW_ is a tool to very quickly create new projects in any language, and deploy new semantic versions of them with any tools you desire.**

  Dependencies
* Ruby >= 1.9.3

  Templates
_NEW_ templates are simply directories & files in a structure for your desired project.

Templates allow quick boilerplating & post-processing scaffolding, and supports interpolating the contents of a file and the file/directory names themselves.

* A `[FOO]_template.rb` file must be included in the root of the template
* `[FOO]_template.rb` file must contain a class of `New::FooTemplate` and inherit from `New::Template`
* `[FOO]_template.rb` file must have a `run` method defined

  Tasks
_NEW_ tasks are ruby scripts that help you create new semantic versions of your project and deploy it any way you like.

* A `foo_task.rb` file must be included in the template directory
* The `.rb` file must contain a class of `New::FooTask` and inherit from `New::Task`
* The `.rb` file must have a `run` method defined

```ruby
# ~/.new/tasks/foo_task/foo_task.rb

class New::FooTask < New::Task
  # required `run` method
  def run
    # do task stuff here

    # access task options from the `options` object
    # access all project options from the `project_options` object
  end
end
```

#### Install
```shell
gem install new
new init
```

### Usage
  Create a new project
```shell
new [TEMPLATE] [NAME]
```

  Release a new version
```shell
new release
```

### Development
  Dependencies

```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/new/master/yuyi_menu
bundle install
```

  Interpolation
* Add `.erb` extension to any file needing its content interpolated
* Interpolate file/directory names using the syntax `foo_[PROJECT.NAME].txt`
* Use dot notation to access nested values
* Access any values from the `.new` configuration file in your home directory, as well as any values from the `.new` configuration file in root of your project directory

```erb
<%# ~/.new/templates/foo_template/foo_[PROJECT.NAME].txt.erb %>

<%= license %>
<%= developer.name %>
<%= developer.email %>
<%= type %>
<%= project.name %>
<%= foo %>
<%= tasks.bar_task.baz %>
```

  Compiling & Testing
Run `bundle exec guard`
