# GEM TASK

###### gemspec attributes

You can add any of the supported gemspec attributes to your project's `.new` configuration file.

```yaml
tasks:
  gem:
    summary: My gem summary
    test_files: <%= Dir.glob('spec/*.rb') %> # use erb rules for inline ruby
```

A full list can be found here http://guides.rubygems.org/specification-reference

The following attributes expect arrays of unix glob patterns

* files
* test_files
* extra_rdoc_files

```yaml
tasks:
  gem:
    gemspec:
      files:
      - 'lib/**/*.rb'
      test_files:
      - 'spec/**/*.rb'
```

The following attributes are automatically set.

* name
* version
* date
