# Hotch

Profile helper

## What?

* Wraps your program run with [stackprof](https://github.com/tmm1/stackprof)
* Dumps profile results
* Converts profile dump using `graphviz` (dot) to SVG
* Optionally shows the call-stack graph

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hotch'
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
