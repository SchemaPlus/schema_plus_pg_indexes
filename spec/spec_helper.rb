require 'simplecov'
require 'simplecov-gem-profile'
SimpleCov.start "gem"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'active_record'
require 'schema_plus_pg_indexes'
require 'schema_dev/rspec'

SchemaDev::Rspec.setup

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include(SchemaPlusPgIndexesMatchers)
  if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new('5.2.0')
    config.filter_run_excluding rails_5_2: :skip
  else
    config.filter_run_excluding rails_5_2: :only
  end
  config.warnings = true
  config.around(:each) do |example|
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Migration.drop_table table, force: :cascade
      end
      example.run
    end
  end
end

def define_schema(&block)
  ActiveRecord::Schema.define do
    ActiveRecord::Base.connection.tables.each do |table|
      drop_table table, force: :cascade
    end
    instance_eval &block
  end
end

SimpleCov.command_name "[ruby #{RUBY_VERSION} - ActiveRecord #{::ActiveRecord::VERSION::STRING} - #{ActiveRecord::Base.connection.adapter_name}]"

