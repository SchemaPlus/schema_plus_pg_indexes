module SchemaPlusPgIndexes
  module ActiveRecord
    module ConnectionAdapters
      module PostgresqlAdapter
        #
        # SchemaPlusPgIndexes allows the column_names paramter
        # to be left off
        #
        def add_index(*args)
          options = args.extract_options!
          table_name, column_names = args
          super table_name, column_names, options
        end
      end
    end
  end
end
