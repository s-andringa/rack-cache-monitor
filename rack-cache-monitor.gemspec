# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/cache/monitor/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-cache-monitor"
  spec.version       = Rack::Cache::Monitor::VERSION
  spec.authors       = ["Sjoerd Andringa"]
  spec.email         = ["rack.cache.monitor@sjoerd.io"]

  spec.summary       = "rack-cache-monitor monitors rack-cache stats such as its hitrate."
  spec.description   = "The rack-cache-monitor middleware lets you monitor rack-cache related stats, such as the number of fresh hits, passes, or its hitrate, and reports them the way you want."
  spec.homepage      = "https://github.com/s-andringa/rack-cache-monitor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
