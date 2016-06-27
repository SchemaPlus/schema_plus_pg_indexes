require 'schema_plus/indexes'
require 'its-it'

require_relative 'schema_plus_pg_indexes/active_record/connection_adapters/index_definition'
require_relative 'schema_plus_pg_indexes/active_record/connection_adapters/postgresql_adapter'
require_relative 'schema_plus_pg_indexes/middleware/postgresql/dumper'
require_relative 'schema_plus_pg_indexes/middleware/postgresql/migration'
require_relative 'schema_plus_pg_indexes/middleware/postgresql/sql'
require_relative 'schema_plus_pg_indexes/middleware/postgresql/schema'
require_relative 'schema_plus_pg_indexes/version'

SchemaMonkey.register SchemaPlusPgIndexes
