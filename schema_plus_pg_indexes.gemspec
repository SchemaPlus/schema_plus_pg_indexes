# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schema_plus_pg_indexes/version'

Gem::Specification.new do |spec|
  spec.name          = "schema_plus_pg_indexes"
  spec.version       = SchemaPlusPgIndexes::VERSION
  spec.authors       = ["ronen barzel"]
  spec.email         = ["ronen@barzel.org"]
  spec.summary       = %q{Adds support in ActiveRecord for PostgreSQL index expressions and operator classes, as well as a shorthand for case-insensitive indexes}
  spec.homepage      = "https://github.com/SchemaPlus/schema_plus_pg_indexes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 4.2"
  spec.add_dependency "schema_plus_indexes", "~> 0.1", ">= 0.1.3"
  spec.add_dependency "schema_plus_core", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "schema_dev", "~> 3.6"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-gem-profile"
end
