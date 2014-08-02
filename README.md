# new
###### install
```shell
gem install new
new init
```

###### Create a new project
```shell
new [TEMPLATE] [NAME]
```

###### Release a new version
```shell
new release
```

#### Templates
Templates represent a boilerplate directory & file structure preconfigured for a given project type. _(eg js, ruby, gem, rails, etc.)_

#### Tasks
Tasks represent a process associated with releasing new code.  Tasks are run in order they are listed in the project `.new` configuration file.

#### Local Config/Templates/Tasks
After running `new init`, you will have `.new` folder in your home directory.  This directory contains:

* `.new` local configuration file
* `tasks` directory for custom tasks
* `templates` directory for custom templates

Copy or create custom templates & tasks in these folders.  They will take precendence over the default templates included with the gem.

**Make sure to edit your local configuration file!**

```yaml
# ~/.new/.new

license: MIT
developer:
  name: Foo Bar
  email: foo@bar.com
templates:
  foo_template:
    custom: option
tasks:
  github:
    username: foouser
```


#### Custom Templates
* The directory name will be used for the template name.
* Templates can have a `.new` file in the root of the folder.  These values can be accessed through interpolation.

```yaml
# ~/.new/templates/foo_template/.new

foo: bar
tasks:
  foo_task:
  bar_task:
    baz: 'baz'
```

_Note: the tasks are followed by a colon `:` whether they have options or not._

###### Interpolation
Use ERB template syntax in your files to interpolate template options.  Make sure to add `.erb` to the end of the filename.

You can also access any custom values set in your local configuration file.

```erb
<%# ~/.new/templates/foo_template/foo.txt.erb %>

<%= license %>
<%= developer.name %>
<%= developer.email %>
<%= type %>
<%= project.name %>
<%= foo %>
<%= tasks.bar_task.baz %>
```

You can also interpolate directory and filenames using the syntax `foo_[DEVELOPER.NAME].txt`

_Note using the dot notation to access nested attributes._

#### Custom Tasks
* The directory name will be used for the task name
* A `.rb` file must be included in the directory with the same name
* The `.rb` file must contain a class of `New::Task::FooTask` and inherit from `New::Task`
* The `.rb` file must have a standard ruby `run` method that will run when a project is released.
* A Task can have an `OPTIONS` constant with default options needed for the task to run.  These can be further customized in the project or local configuration `.new` file

```ruby
# ~/.new/tasks/foo_task/foo_task.rb

class New::Task::FooTask < New::Test
  include New::Interpolate  # if you need to interpolate files
  include New::version      # if you need to set & manage a semantic version

  # defaults for required options
  OPTION = {
    foo: 'bar'
  }

  # required `run` method
  def run
    # do task stuff here

    access
    # access task options from the `options` object
    # access all project options from the `project_options` object
  end
end
```

#### TODO
* optional scripts when creating a template
* write templates
* write tasks

#### Contributing
1. Fork it ( http://github.com/brewster1134/new/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
