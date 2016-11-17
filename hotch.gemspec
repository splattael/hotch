# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hotch/version'

Gem::Specification.new do |spec|
  spec.name          = "hotch"
  spec.version       = Hotch::VERSION
  spec.authors       = ["Peter Suschlik"]
  spec.email         = ["peter@suschlik.de"]
  spec.summary       = %q{Profile helper}
  spec.description   = %q{Stackprofs your program, generates/display call-stack profile as SVG}
  spec.homepage      = "https://github.com/splattael/hotch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "stackprof", "~> 0.2.10"
  spec.add_runtime_dependency "allocation_tracer", "~> 0.6.3"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
