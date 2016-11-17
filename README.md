# Hotch

[![Gem Version](https://img.shields.io/gem/v/hotch.svg)](https://rubygems.org/gems/hotch)
[![Source code](https://img.shields.io/badge/code-GitHub-blue.svg)](https://github.com/splattael/hotch)

Profile helper

## What?

* Wraps your program run with [stackprof](https://github.com/tmm1/stackprof)
* Dumps profile results
* Converts a profile dump using [graphviz](http://www.graphviz.org/) (dot) to SVG
* Optionally shows the call-stack graph after program exit

## Example

From [dry-validation](https://github.com/dry-rb/dry-validation) [benchmarks/profile_schema_call_valid.rb](https://github.com/dry-rb/dry-validation/blob/3d090eeafac9d1c31fdc3e054f8fd5ec900e12f9/benchmarks/profile_schema_call_valid.rb):

![dry-validation](images/dry-validation.profile_schema_call_valid.png?raw=true "benchmarks/profile_schema_call_valid.rb")

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hotch', '~> 0.3.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hotch

## Usage

### Profile complete program

    $ ruby -rhotch/run my_program.rb
    Profile SVG: /tmp/hotch.my_program20150104-17330-18t4171/profile.svg
    $ view /tmp/hotch.my_program20150104-17330-18t4171/profile.svg

### Profile blocks in your program

```ruby
require 'hotch'

def expensive_method
  # ...
end

Hotch() do
  1000.times do
    expensive_method
  end
end

Hotch(aggregate: false) do
  1000.times do
    # this run is not aggregated
  end
end

Hotch() do
  1000.times do
    # aggregated again
  end
end
```

### Auto-view

Set envvar `HOTCH_VIEWER` to enable auto-view after profiling.

    $ export HOTCH_VIEWER=eog # use Gnome viewer

### Filter

Set envvar `HOTCH_FILTER` to (regexp) filter frames by its name.

    $ export HOTCH_FILTER=ROM
    $ export HOTCH_FILTER=Bundler

### Minitest integration

Load `hotch/minitest` in your `test/test_helper.rb` like this:

```ruby
require 'minitest/autorun'
require 'hotch/minitest'

Hotch::Minitest.run
Hotch::Minitest.run(filter: /MyClass/)
Hotch::Minitest.run(options: <stackprof options>)
Hotch::Minitest.run(options: { limit: 200 })
```

## Caveat

### Using with bundler

If you use `hotch` in project managed by `bundler` you have to specify `hotch` in `Gemfile`.(see Installation section above)

## Contributing

1. Fork it ( https://github.com/splattael/hotch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Release

Follow these steps to release this gem:

    # Increase version
    edit lib/hotch/version.rb
    edit README.md
    # Commit
    git commit -m "Release vX.Y.Z"
    rake release
