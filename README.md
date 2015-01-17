[![Gem Version](https://badge.fury.io/rb/new.svg)](http://badge.fury.io/rb/new)
[![Build Status](https://travis-ci.org/brewster1134/new.svg?branch=master)](https://travis-ci.org/brewster1134/new)
[![Coverage Status](https://coveralls.io/repos/brewster1134/new/badge.png)](https://coveralls.io/r/brewster1134/new)
[![WTFPL](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png)](http://www.wtfpl.net)

# NEW
A flexible tool for releasing your code into the wild.

### Dependencies
*

---
## Markup
> HTML

>```html
<div>
</div>
```

> CSS
>```sass
.<>name.file<>
```

> JS
>```coffee
->
```

---
## Methods
> **name** _description_

> _Arguments_
>```yaml
arg: [Type] description
  default:
```

> _Usage_
>```coffee
->
```

---
## Events
> **name** _description_

> _Arguments_
>```yaml
arg: [Type] description
  default:
```

> _Usage_
>```coffee
->
```

## Development
### Dependencies

```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/<>github.username<>/<>name.file<>/master/Yuyifile
bundle install
npm install
bower install
```

>Do **NOT** modify any `.js` files!  Modify the `src` files and Testem will watch for changes and compile them to the correct directory.

### Compiling & Testing
```shell
testem
```
