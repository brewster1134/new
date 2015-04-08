# Task Development

---
###### File Name
* File should be in a directory that matches the task name
* Both the file and the directory should...
  * be lowercase
  * be underscore seperated
* Suffixed with `_task`
* Have a `.rb` extension

```shell
# e.g. a task named `foo`
foo
 |-- foo_task.rb
```

---
###### Class
* Namespaced with `New`
* CamelCased version of the file name
* Inherit from `New::Task`
* Set `@@description` _required_
* Set `@@options` _optional_
* Define `verify` method _optional_
* Define `run` method _required_

You can access user provided options through the `@options` object.

```ruby
class New::FooTask < New::Task
  @@description = 'Description of the foo task'
  @@options = {} # see Options section below

  def verify
    # check to make sure dependencies to run the task are met
    # e.g. checking that a binary exists
  end

  def run
    # steps to run the task
  end
end
```

---
###### Newfile Options
A user can pass options into a task from the project's Newfile

```yaml
tasks:
  foo:
    foo_option: value
```

---
###### Task Options
Each option should be defined in your task. The key will be the option name.

* Hash of supported attributes with the following format of key/value pairs...
  * `option name`
    * `description`: [String] a short description of this option
    * `required`: [Boolean] enforces that an option is set. _(see required section below)_
    * `type`: [Object] expected ruby class type _(String, Symbol, Boolean, Integer, Float, Array, Hash)_
    * `validation` [Various] depending on the type specified, there are different validation options _(see validation section below)_
    * `default` [Various] an optional default value.
* `default` is ignored if `required` is set to `true`

```ruby
class New::FooTask < New::Task
  @@options = {
    :foo_option => {
      :description => 'description of this option'
      :required => false,
      :type => String,
      :validation => /foo_.+_bar/
      :default => 'foo_value'
    }
  }

  # ...
end
```

---
###### Option Types
When an option type is set _(default is `String`)_, user-provided values are converted to the given type.
* `Symbol`: converts to simplified unquoted symbol format _(e.g. :foo_bar)_
  * lowercase
  * non-alpha characters converted to underscore
  * underscores removed from the 1st & last character
* `Boolean`: converts strings `true` & `false` to actual boolean

---
###### Option Required
When required _(default is `false`)_, all option types are checked against being nil, but depending on the type, additional checks are made.
* `String`: checks that it is not an empty string
* `Symbol`: checks that is is not an empty string before converting to a symbol
* `Array`: checks that array is not empty
* `Hash`: checks that hash is not empty

---
###### Option Validation
All option types are validated against being able to be cast into their object type, but depending on the type, additional validations can be made.
* `String`
  * `Regex`: _(e.g. `/[a-z]{5}/`)_
* `Symbol`
  * `Regex`: _(e.g. `/[_a-z]{5}/`)_
* `Integer`
  * `Range`: _(e.g. `(1..10)`)_
* `Float`
  * `Range`: _(e.g. `(1.5..10.5)`)_
* `Array`
  * `Class`: checks that the array contains (or can be converted to) a particuar ruby class type _(e.g. `String`)_
  * `Array`: returns an array of hashes, each with the provided keys _e.g. `[:foo]` would validate true with `[{ :foo => 'bar' }, { :foo => 'baz' }]`_
* `Hash`
  * `Array`: An array of required key names _(e.g. `[:foo, :bar]`)_
  * `Hash`: An object of required key names, and type values _(e.g. `{ :foo => Integer, :bar => Boolean }`)_

# Task Spec Development

---
###### File Name
* File should be in the same directory as the task file
* File should match the task file, but suffixed with `_spec`

```shell
# e.g. a task named `foo`
foo
 |-- foo_task.rb
 |-- foo_task_spec.rb
```

---
###### Rspec
* Needs to `require` the `new` library
* Needs to `require_relative` the task library
* Namespaced with `New`
* `describe` using the namespaced task class

```ruby
require 'new'
require_relative 'foo_task'

describe New::FooTask do
end
```
