[![gem version](https://badge.fury.io/rb/new.svg)](https://rubygems.org/gems/new)
[![dependencies](https://gemnasium.com/brewster1134/new.svg)](https://gemnasium.com/brewster1134/new)
[![docs](http://inch-ci.org/github/brewster1134/new.svg?branch=master)](http://inch-ci.org/github/brewster1134/new)
[![build](https://travis-ci.org/brewster1134/new.svg?branch=master)](https://travis-ci.org/brewster1134/new)
[![coverage](https://coveralls.io/repos/brewster1134/new/badge.svg?branch=master)](https://coveralls.io/r/brewster1134/new?branch=master)
[![code climate](https://codeclimate.com/github/brewster1134/new/badges/gpa.svg)](https://codeclimate.com/github/brewster1134/new)

[![omniref](https://www.omniref.com/github/brewster1134/new.png)](https://www.omniref.com/github/brewster1134/new)

# NEW
A flexible tool for releasing your code into the wild.

---
#### Quick Usage
```shell
gem install new
cd /my/project/dir
new init -n "My Project Name" -v "1.2.3"
new release
```

---
#### Global Newfile
You can set defaults in a Newfile in your home directory. These options will always be loaded whenever new runs. This is a great place to add your custom sources. You can use any format supported by [Sourcerer](https://github.com/brewster1134/sourcerer)
```yaml
sources:
  local: /path/to/local/new-tasks
  remote: my-github-username/repo-with-new-tasks
```

---
#### Project Newfile
To use new, you need to have a Newfile in the root of the project. The Newfile is a YAML formatted file containing information about your project. A `name`, `version`, and at least 1 `task` is required.

* Run `new init` from your project directory to create your Newfile _*see Quick Usage above_
* Run `new tasks` to view all available tasks

###### Required options
* `name`: The name of your project
* `version`: The current verison of your software
* `tasks`: A list of tasks (and their options) to run in order

```yaml
name: My Project Name
version: 1.2.3
tasks:
  github:
    username: brewster1134
  gem:
    gemspec:
      author: Ryan Brewster
      summary: Project summary
```

---
#### Release New Version
To release a new version of your software, simply run `new release` from your project's root. You will be prompted to choose what new semantic version you want to release. Make sure to follow [semantic versioning rules](http://semver.org/)!
```shell
new release
```

---
#### Commands
Run `new help` to view available commands

---
#### Development
###### Install Dependencies
```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/new/master/Yuyifile
bundle install
```

###### To test the new gem...
```shell
bundle exec guard
```

###### To test tasks...
```shell
new test
```

* You can use the `-w` flag to watch local tasks and automatically run the tests when there are file changes.
* You can specify a source, a task, or both to test with the following options.

```shell
Options:
-w, [--watch], [--no-watch]  # Watch local tasks for changes and run tests
-s, [--source=SOURCE]        # Source name
-t, [--task=TASK]             name

# e.g. to watch a local `gem` task specified by a source named `local`
new tasks -w -s local -t gem
```

[![WTFPL](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png)](http://www.wtfpl.net)
