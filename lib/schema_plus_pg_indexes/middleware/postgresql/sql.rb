module SchemaPlusPgIndexes
  module Middleware
    module Postgresql
      module Sql

        module IndexComponents

          # SchemaPlusPgIndexes provides the following extra options for PostgreSQL
          # indexes:
          # * +:expression+ - SQL expression to index.  column_name can be nil or ommitted, in which case :name must be provided
          # * +:operator_class+ - an operator class name or a hash mapping column name to operator class name
          # * +:case_sensitive - setting to +false+ is a shorthand for :expression => 'LOWER(column_name)'
          #
          # The <tt>:case_sensitive => false</tt> option ties in with Rails built-in support for case-insensitive searching:
          #    validates_uniqueness_of :name, :case_sensitive => false
          #
          # Since since <tt>:case_sensitive => false</tt> is implemented by
          # using <tt>:expression</tt>, this raises an ArgumentError if both
          # are specified simultaneously.
          #
          def around(env)
            options = env.options
            column_names = env.column_names
            table_name = env.table_name
            connection = env.connection

            if env.column_names.empty?
              raise ArgumentError, "No columns and :expression missing from options - cannot create index" unless options[:expression]
              raise ArgumentError, "No columns, and index name not given. Pass :name option" unless options[:name]
            end

            expression = options.delete(:expression)
            operator_classes = options.delete(:operator_class)
            case_insensitive = (options.delete(:case_sensitive) == false)

            if expression
              raise ArgumentError, "Cannot specify :case_sensitive => false with an expression.  Use LOWER(column_name)" if case_insensitive
              expression.strip!
              if m = expression.match(/^using\s+(?<using>\S+)\s*(?<rest>.*)/i)
                options[:using] = m[:using]
                expression = m[:rest]
              end
              if m = expression.match(/^(?<rest>.*)\s+where\s+(?<where>.*)/i)
                options[:where] = m[:where]
                expression = m[:rest]
              end
            end

            yield env

            if operator_classes and not operator_classes.is_a? Hash
              operator_classes = Hash[column_names.map {|name| [name, operator_classes]}]
            end

            if expression
              env.sql.columns = expression
            elsif operator_classes or case_insensitive
              option_strings = Hash[column_names.map {|name| [name, '']}]
              (operator_classes||{}).stringify_keys.each do |column, opclass|
                option_strings[column] += " #{opclass}" if opclass
              end
              option_strings = connection.send :add_index_sort_order, option_strings, column_names, options

              if case_insensitive
                caseable_columns = connection.columns(table_name).select { |col| [:string, :text].include?(col.type) }.map(&:name)
                quoted_column_names = column_names.map do |col_name|
                  (caseable_columns.include?(col_name.to_s) ? "LOWER(#{connection.quote_column_name(col_name)})" : connection.quote_column_name(col_name)) + option_strings[col_name]
                end
              else
                quoted_column_names = column_names.map { |col_name| connection.quote_column_name(col_name) + option_strings[col_name] }
              end

              env.sql.columns = quoted_column_names.join(', ')
            end
          end
        end
      end
    end
  end
end
