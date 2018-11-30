require 'schema_plus/indexes'
require 'its-it'

if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('5.2.0')
  require_relative 'schema_plus_pg_indexes/active_record/connection_adapters/index_definition'
  require_relative 'schema_plus_pg_indexes/active_record/connection_adapters/postgresql_adapter'
  require_relative 'schema_plus_pg_indexes/middleware/postgresql/dumper'
  require_relative 'schema_plus_pg_indexes/middleware/postgresql/migration'
  require_relative 'schema_plus_pg_indexes/middleware/postgresql/sql'
  require_relative 'schema_plus_pg_indexes/middleware/postgresql/schema'
else
  ActiveSupport::Deprecation.warn('Schema+ PG Indexes is deprecated for ActiveRecord 5.2 and up. Please see the README.md for more details.')
  require_relative 'schema_plus_pg_indexes/active_record/connection_adapters/index_definition_5_2'
  require_relative 'schema_plus_pg_indexes/middleware/postgresql/migration_5_2'
end
require_relative 'schema_plus_pg_indexes/version'

SchemaMonkey.register SchemaPlusPgIndexes
