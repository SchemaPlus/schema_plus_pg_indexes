module SchemaPlusPgIndexes
  module Middleware
    module Postgresql
      module Dumper

        def self.insert
          SchemaMonkey::Middleware::Dumper::Indexes.append DumpExtensions
          SchemaMonkey::Middleware::Dumper::Table.append InlineIndexes
        end

        class DumpExtensions < SchemaMonkey::Middleware::Base
          def call(env)
            continue env

            index_defs = Dumper.get_index_defiinitions(env, env.table)

            env.table.indexes.each do |index_dump|
              index_def = index_defs.find(&its.name == index_dump.name)
              if index_def.columns.blank?
                index_dump.add_option "expression: #{index_def.expression.inspect}" if index_def.expression and index_def.columns.blank?
              else
                index_dump.add_option "case_sensitive: false" unless index_def.case_sensitive?
                unless index_def.operator_classes.blank?
                  if index_def.operator_classes.values.uniq.length == 1
                    index_dump.add_option "operator_class: #{index_def.operator_classes.values.first.inspect}"
                  else
                    index_dump.add_option "operator_class: {" + index_def.operator_classes.map{|column, val| "#{column.inspect}=>#{val.inspect}"}.join(", ") + "}"
                  end
                end
              end
            end
          end
        end

        class InlineIndexes < SchemaMonkey::Middleware::Base
          def call(env)
            continue env

            index_defs = Dumper.get_index_defiinitions(env, env.table)

            env.table.indexes.select(&its.columns.blank?).each do |index|
              env.table.statements << "t.index name: #{index.name.inspect}, #{index.options}"
              env.table.indexes.delete(index)
            end
          end
        end

        def self.get_index_defiinitions(env, table_dump)
          env.dump.data.index_definitions ||= {}
          env.dump.data.index_definitions[table_dump.name] ||= env.connection.indexes(table_dump.name)
        end
      end
    end
  end
end
