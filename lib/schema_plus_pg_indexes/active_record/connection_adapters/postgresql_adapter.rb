module SchemaPlusPgIndexes
  module ActiveRecord
    module ConnectionAdapters
      module PostgresqlAdapter
        #
        # SchemaPlusPgIndexes allows the column_names parameter
        # to be left off
        #
        def add_index(table_name, column_names, options={})
          column_names, options = [nil, column_names] if column_names.is_a? Hash
          super table_name, column_names, options
        end
      end
    end
  end
end
