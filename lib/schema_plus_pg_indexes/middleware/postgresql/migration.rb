module SchemaPlusPgIndexes
  module Middleware
    module Postgresql
      module Migration

        module Index
          # Deprecate args
          def before(env)
            {:conditions => :where, :kind => :using}.each do |deprecated, proper|
              if env.options[deprecated]
                ActiveSupport::Deprecation.warn "ActiveRecord index option #{deprecated.inspect} is deprecated, use #{proper.inspect} instead"
                env.options[proper] = env.options.delete(deprecated)
              end
            end

            case env.caller.class.name
            when /TableDefinition/
              # When index creation is in table definition, create a dummy value for column_names,
              # since index definitions are indexed by column names
              env.column_names = dummy_column_names(env) if env.column_names.blank?
            else
              # For actual index creation, strip out the dummy column name
              # value
              env.column_names = [] if env.column_names == dummy_column_names(env)
            end
          end

          def dummy_column_names(env)
            ["--expression--", env.options[:expression]]
          end
        end
      end
    end
  end
end
