# frozen_string_literal: true

# frozen_string_literals: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hotch/version"

Gem::Specification.new do |spec|
  spec.name          = "hotch"
  spec.version       = Hotch::VERSION
  spec.authors       = ["Peter Leitzen"]
  spec.email         = ["peter@leitzen.de"]
  spec.summary       = "Profile helper"
  spec.description   = "Callstack and memory profiler"
  spec.homepage      = "https://github.com/splattael/hotch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_runtime_dependency "allocation_tracer", "~> 0.6.3"
  spec.add_runtime_dependency "stackprof", "~> 0.2.15"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "rubocop-rake"
  spec.metadata["rubygems_mfa_required"] = "true"
end
