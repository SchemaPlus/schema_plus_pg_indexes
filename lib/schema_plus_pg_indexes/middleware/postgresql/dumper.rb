module SchemaPlusPgIndexes
  module Middleware
    module Postgresql
      module Dumper
        module Table

          # Dump index extensions
          def after(env)
            index_defs = env.connection.indexes(env.table.name)

            env.table.columns.each do |column_dump|
              index = column_dump.options[:index]
              set_index_options(index[:name], index, index_defs) if index
            end

            env.table.indexes.each do |index_dump|
              set_index_options(index_dump.name, index_dump.options, index_defs)
            end
          end

          def set_index_options(name, options, index_defs)
            index_def = index_defs.find(&its.name == name)
            options[:case_sensitive] = false unless index_def.case_sensitive?
            options[:expression] = index_def.expression if index_def.expression and index_def.case_sensitive?
            unless index_def.operator_classes.blank?
              if index_def.columns.uniq.length <= 1 && index_def.operator_classes.values.uniq.length == 1
                options[:operator_class] = index_def.operator_classes.values.first
              else
                options[:operator_class] = index_def.operator_classes
              end
            end
          end


        end
      end
    end
  end
end
