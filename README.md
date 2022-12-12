# Hotch

[![Gem Version](https://img.shields.io/gem/v/hotch.svg)](https://rubygems.org/gems/hotch)
[![Source code](https://img.shields.io/badge/code-GitHub-blue.svg)](https://github.com/splattael/hotch)

Profile helper

## What?

### Callstack profiler

* Wraps your program run with [stackprof](https://rubygems.org/gems/stackprof)
* Dumps profile results
* Converts a profile dump using [graphviz](http://www.graphviz.org/) (dot) to SVG
* Optionally shows the call-stack graph after program exit

### Memory profiler

* Traces memory allocation using [allocation_tracer](https://rubygems.org/gems/allocation_tracer)
* Prints the results formatted and sorted by object count

## Example

### Callstack profiler

From [dry-validation](https://github.com/dry-rb/dry-validation) [benchmarks/profile_schema_call_valid.rb](https://github.com/dry-rb/dry-validation/blob/3d090eeafac9d1c31fdc3e054f8fd5ec900e12f9/benchmarks/profile_schema_call_valid.rb):

![dry-validation](images/dry-validation.profile_schema_call_valid.png?raw=true "benchmarks/profile_schema_call_valid.rb")

### Memory profiler

```
                        filename     type count old_count total_age min_age max_age total_memsize
                    inline.rb:28  T_IMEMO     1         0         0       0       0             0
dry/struct/class_interface.rb:74  T_IMEMO     1         0         0       0       0             0
dry/struct/class_interface.rb:77  T_IMEMO     1         0         0       0       0             0
       dry/types/decorator.rb:28  T_IMEMO     1         0         0       0       0             0
     dry/types/hash/schema.rb:96  T_IMEMO     2         0         0       0       0             0
     dry/types/hash/schema.rb:52  T_IMEMO     2         0         0       0       0             0
                    inline.rb:27 T_STRING  1000         0         0       0       0             0
                    inline.rb:28   T_HASH  1000         0         0       0       0             0
                    inline.rb:26   T_HASH  1000         0         0       0       0             0
     dry/types/hash/schema.rb:92   T_HASH  2000         0         0       0       0             0
     dry/types/hash/schema.rb:60   T_HASH  2000         0         0       0       0             0
             dry/logic/rule.rb:0  T_ARRAY  2000         0         0       0       0             0
            dry/logic/rule.rb:47 T_OBJECT  2000         0         0       0       0             0
      dry/types/definition.rb:59 T_OBJECT  2000         0         0       0       0             0
dry/struct/class_interface.rb:77 T_OBJECT  2000         0         0       0       0             0
     dry/types/constrained.rb:20   T_DATA  4000         0         0       0       0             0
     dry/types/constrained.rb:27  T_ARRAY  4000         0         0       0       0             0
            dry/logic/rule.rb:47  T_ARRAY  4000         0         0       0       0             0
            dry/logic/rule.rb:47   T_DATA  4000         0         0       0       0             0
      dry/types/definition.rb:51  T_ARRAY  4000         0         0       0       0             0
     dry/types/hash/schema.rb:92  T_ARRAY  6000         0         0       0       0             0
                dry/struct.rb:16 T_STRING  6000         0         0       0       0             0
                           TOTAL          47008         0         0       0       0             0
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hotch', '~> 0.6.0'
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

### Memory profiler

Shell usage:

    $ ruby -rhotch/memory/run my_program.rb

Require `hotch/memory` and use `Hotch.memory { ... }` as in:

```ruby
require "bundler/setup"

require "dry-types"
require "dry-struct"
require "hotch/memory"

module Types
  class IntStruct < Dry::Struct
    include Dry::Types.module
    constructor_type :strict
    attribute :int, Strict::Int
  end

  class Success < Dry::Struct
    include Dry::Types.module
    constructor_type :strict
    attribute :string, Strict::String
    attribute :sub, Types::IntStruct
  end
end

# For more stable results the GC is disabled by default during runs.
Hotch.memory do
  1000.times do
    Types::Success.new(
      :string => "string",
      :sub => Types::IntStruct.new(:int => 1)
    )
  end
end

# In order to prevent disabling the GC during runs do:
Hotch.memory(disable_gc: false) do
  # ...
end

# Disable aggregation between runs:
Hotch.memory(aggregate: false) do
  # this run is not aggregated
end
```

#### Inline reporting

This prints two ASCII tables showing the object alloctions two calls:

```ruby
puts Hotch::Memory.report("memory") {
  # ...
}

puts Hotch::Memory.report("another") {
  # ...
}
```

### Minitest integration for the memory profiler

Load `hotch/memory/minitest` in your `test/test_helper.rb` like this:

```ruby
require 'minitest/autorun'
require 'hotch/memory/minitest'

Hotch::Memory::Minitest.run
Hotch::Memory::Minitest.run(name: "my name")
Hotch::Memory::Minitest.run(disable_gc: false) # on by default
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
    git commit -am "Release vX.Y.Z"
    rake release
