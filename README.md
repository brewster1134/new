# new
Opinionated Project Creation

##### Usage
```shell
gem install new
new init
new [TEMPLATE] [NAME]
```

##### Templates
* `js`

##### Custom Templates
Copy or create folders in your `~/.new/templates` folder.

_Note: These templates will take precendence over the default templates included with the gem._

###### Requirements
Template need to have a `.new` file in the root.

```yaml
tasks:
  foo:
  bar:
    option: baz
```

_Note: the tasks are followed by a colon (:) whether they have options or not _

###### Interpolation
Use ERB template syntax in your files to interpolate template data.  Make sure to add `.erb` to the end of the filename.

You can also access any custom values set in your `~/.new/.new` config file.

_`foo.txt.erb`_
```erb
<%= license %>
<%= developer.name %>
<%= developer.email %>
<%= type %>
<%= project_name %>
<%= custom %>
```

You can also interpolate directory and filenames using the syntax `foo_[DEVELOPER.NAME].txt`

_Note using the dot notation to access nested attributes._

##### TODO
* common rake tasks (eg push to github)
* rake tasks per template type (eg gem: publish to rubygems)
* custom rake tasks (from ~/.new/tasks)

##### Contributing
1. Fork it ( http://github.com/brewster1134/new/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
