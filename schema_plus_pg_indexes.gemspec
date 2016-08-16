# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schema_plus_pg_indexes/version'

Gem::Specification.new do |gem|
  gem.name          = "schema_plus_pg_indexes"
  gem.version       = SchemaPlusPgIndexes::VERSION
  gem.authors       = ["ronen barzel"]
  gem.email         = ["ronen@barzel.org"]
  gem.summary       = %q{Adds support in ActiveRecord for PostgreSQL index expressions and operator classes, as well as a shorthand for case-insensitive indexes}
  gem.homepage      = "https://github.com/SchemaPlus/schema_plus_pg_indexes"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activerecord", "~> 5.0"
  gem.add_dependency "schema_plus_indexes", "~> 0.1", ">= 0.1.3"
  gem.add_dependency "schema_plus_core", "~> 2.0"
  gem.add_dependency "its-it", "~> 1.2"

  gem.add_development_dependency "bundler", "~> 1.7"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.0.0"
  gem.add_development_dependency "schema_dev", "~> 3.6"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "simplecov-gem-profile"
end
