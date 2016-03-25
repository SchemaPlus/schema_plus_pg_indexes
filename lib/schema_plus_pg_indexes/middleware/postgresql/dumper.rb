module SchemaPlusPgIndexes
  module Middleware
    module Postgresql
      module Dumper

        module Indexes

          # Dump index extensions
          def after(env)
            index_defs = Dumper.get_index_definitions(env, env.table)

            env.table.indexes.each do |index_dump|
              index_def = index_defs.find(&its.name == index_dump.name)
              index_dump.options[:case_sensitive] = false unless index_def.case_sensitive?
              index_dump.options[:expression] = index_def.expression if index_def.expression and index_def.case_sensitive?
              unless index_def.operator_classes.blank?
                if index_def.columns.uniq.length <= 1 && index_def.operator_classes.values.uniq.length == 1
                  index_dump.options[:operator_class] = index_def.operator_classes.values.first
                else
                  index_dump.options[:operator_class] = index_def.operator_classes
                end
              end
            end
          end
        end

        module Table

          # Move index definitions inline
          def after(env)
            index_defs = Dumper.get_index_definitions(env, env.table)

            env.table.indexes.select(&its.columns.blank?).each do |index|
              env.table.statements << "t.index #{{name: index.name}.merge(index.options).to_s.sub(/^{(.*)}$/, '\1')}"
              env.table.indexes.delete(index)
            end
          end
        end

        def self.get_index_definitions(env, table_dump)
          env.dump.data.index_definitions ||= {}
          env.dump.data.index_definitions[table_dump.name] ||= env.connection.indexes(table_dump.name)
        end
      end
    end
  end
end
