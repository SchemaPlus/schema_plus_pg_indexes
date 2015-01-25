module SchemaPlusIndexes
  module Middleware
    module Dumper

      def self.insert
        SchemaMonkey::Middleware::Dumper::Table.append ColumnIndexes
      end

      class ColumnIndexes < SchemaMonkey::Middleware::Base
        def call(env)
          continue env

          # move each column's index to its column, and remove them from the
          # list of indexes that AR would dump after the table.  Any left
          # over will still be dumped by AR.
          env.table.columns.each do |column|
            
            # first check for a single-column index
            if (index = env.table.indexes.find(&its.columns == [column.name]))
              column.add_option column_index(env, column, index)
              env.table.indexes.delete(index)
              
            # then check for the first of a multi-column index
            elsif (index = env.table.indexes.find(&its.columns.first == column.name))
              column.add_option column_index(env, column, index)
              env.table.indexes.delete(index)
            end

          end

        end

        def column_index(env, column, index)
          parts = []
          parts << "name: #{index.name.inspect}"
          parts << "with: #{(index.columns - [column.name]).inspect}" if index.columns.length > 1
          parts << index.options unless index.options.blank?
          "index: {#{parts.join(', ')}}"
        end
      end
    end
  end
end
