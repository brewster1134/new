# Task Development
#### Required
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
###### Class Name
* Namespaced with `New`
* CamelCased version of the file name
* Inherit from `New::Task`
e.g. a task named `foo`

---
###### Initialize Method
* accepts a single argument of options

```ruby
class New::FooTask < New::Task
  def initialize options
  end
end
```

---
#### Optional
---
###### Options Object
The options object defines the supported options that a user can set in their project's Newfile. This is the best way to prevent user error.

```yaml
# e.g. a Newfile in a user's project
tasks:
  foo:
    foo_option: value
```

* Class-level constant called `OPTIONS` _(all caps)_
* Hash of supported attributes with the following format of key/value pairs...
  * `option name`
    * `required`: [Boolean] enforces that an option is set. _(see required section below)_
    * `type`: [Object] expected ruby class type _(String, Symbol, Boolean, Integer, Float, Array, Hash)_
    * `validation` [Various] depending on the type specified, there are different validation options _(see validation section below)_
    * `default` [Various] an optional default value.
* `default` is ignored if `required` is set to `true`

```ruby
class New::FooTask < New::Task
  OPTIONS = {
    :foo_option => {
      :description => 'description of this option'
      :required => false,
      :type => String,
      :validation => /foo_.+_bar/
      :default => 'foo_value'
    }
  }

  def initialize options
  end
end
```

###### Option Type
When an option type is set _(default is `String`)_, user-provided values are converted to the given type.
* `Symbol`: converts to simplified unquoted symbol format _(e.g. :foo_bar)_
  * lowercase
  * non-alpha characters converted to underscore
  * underscores removed from the 1st & last character
* `Boolean`: converts strings `true` & `false` to actual boolean

###### Option Required
When required _(default is `false`)_, all option types are checked against being nil, but depending on the type, additional checks are made.
* `String`: checks that it is not an empty string
* `Symbol`: checks that is is not an empty string before converting to a symbol
* `Array`: checks that array is not empty
* `Hash`: checks that hash is not empty

###### Option Validation
All option types are validated against being able to be cast into their object type, but depending on the type, additional validations can be made.
* `String`
  * `Regex`: _(e.g. /[a-z]{5}/)_
* `Symbol`
  * `Regex`: _(e.g. /[_a-z]{5}/)_
* `Integer`
  * `Range`: (1..10)
* `Float`
  * `Range`: (1.5..10.5)
* `Array`
  * `Class`: checks that the array contains (or can be converted to) a particuar ruby class type _(e.g. String)_
* `Hash`
  * `Array`: An array of required key names _(e.g. [:foo, :bar])_
  * `Hash`: An object of required key names, and type values _(e.g. { :foo => Integer, :bar => Boolean })_

# Task Spec Development
#### Required

---
###### File Name
* File should be in the same directory as the task file
* File should match the task file, but suffixed with `_spec`

e.g. a task named `foo`
```
foo
|-- foo_task.rb
|-- foo_task_spec.rb
```

---
###### Rspec
* Needs to `require` the `new` library, and `require_relative` the task library
* Namespaced with `New`
* `describe` using the namespaced task class

```ruby
require 'new'
require_relative 'foo_task'

describe New::FooTask do
end
```
