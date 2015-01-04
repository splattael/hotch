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

    $ ruby -rhotch my_program.rb
    Profile SVG: /tmp/hotch.my_program20150104-17330-18t4171/profile.svg
    $ view /tmp/hotch.my_program20150104-17330-18t4171/profile.svg

### Auto-view

Set envvar `HOTCH_VIEWER` to enable auto-view after profiling.

    $ export HOTCH_VIEWER=eog # use Gnome viewer

## Caveat

### Using with bundler

If you use `hotch` in project managed by `bundler` you have to specify `hotch` in `Gemfile`.(see Installation section above)

## Contributing

1. Fork it ( https://github.com/splattael/hotch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
