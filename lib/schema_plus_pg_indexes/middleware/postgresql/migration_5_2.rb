module SchemaPlusPgIndexes
  module Middleware
    module Postgresql
      module Migration

        module Index
          # Deprecate args
          def before(env)
            {:conditions => :where, :kind => :using, :operator_classes => :opclasses}.each do |deprecated, proper|
              if env.options[deprecated]
                ActiveSupport::Deprecation.warn "ActiveRecord index option #{deprecated.inspect} is deprecated, use #{proper.inspect} instead"
                env.options[proper] = env.options.delete(deprecated)
              end
            end

            if env.options[:expression]
              ActiveSupport::Deprecation.warn "ActiveRecord index option expression is deprecated, simply define the expressions in :columns instead"
              env.column_names << env.options.delete(:expression)
            end
          end
        end
      end
    end
  end
end
