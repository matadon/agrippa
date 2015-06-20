# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "agrippa/version"

Gem::Specification.new do |spec|
    spec.name = "agrippa"
    spec.version = Agrippa::VERSION
    spec.authors = ["Don Werve"]
    spec.email = ["don@werve.net"]
    spec.summary = %q{Tools for building better code.}
    spec.description = %q{A small collection of design patterns, codified in a gem for easy reuse.}
    spec.homepage = "https://github.com/mataton/agrippa/"
    spec.license = "Apache-2.0"
    spec.files = `git ls-files -z`.split("\x0")
    spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
    spec.require_paths = ["lib"]
    spec.add_development_dependency "bundler", "~> 1.6"
    spec.add_development_dependency "rake", "~> 10.0"
    spec.add_development_dependency "rspec", "~> 3.0", ">= 3.0.0"
    spec.add_development_dependency "guard", "~> 2.8"
    spec.add_development_dependency "guard-rspec", "~> 4.3"
    spec.add_development_dependency "ruby_gntp", "~> 0"
    spec.add_development_dependency "simplecov", "~> 0"
    spec.add_development_dependency "pry", "~> 0"
    spec.add_development_dependency 'hamster', '~> 1.0', '>= 1.0.0'
end
