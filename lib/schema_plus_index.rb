require 'schema_monkey'

# Load any mixins to ActiveRecord modules, such as:
#
#   require_relative 'schema_plus_index/active_record/base'
#   require_relative 'schema_plus_index/active_record/connection_adapters/abstract_adapter'
#
# Any modules named SchemaPlusIndex::ActiveRecord::<remainder-of-submodule-path>
# will be automatically #include'd in their counterparts in ::ActiveRecord


# Load any middleware, such as:
#
#   require_relative 'schema_plus_index/middleware/model'
#
# Any modules named SchemaPlusIndex::Middleware::<submodule-path> will
# automatically have their .insert method called.

# Database adapter-specific mixin, if any, will automatically #include'd in
# its counterpart depending on which database adapter is in use.
module SchemaPlusIndex
  module ActiveRecord
    module ConnectionAdapters
      # autoload :MysqlAdapter, 'schema_plus_tables/active_record/connection_adapters/mysql_adapter'
      # autoload :PostgresqlAdapter, 'schema_plus_tables/active_record/connection_adapters/postgresql_adapter'
      # autoload :Sqlite3Adapter, 'schema_plus_tables/active_record/connection_adapters/sqlite3_adapter'
    end
  end
end



# Extra load-time initialization can go here.  You can delete this if you don't have any.
module SchemaPlusIndex
  def self.insert
  end
end

SchemaMonkey.register(SchemaPlusIndex)
