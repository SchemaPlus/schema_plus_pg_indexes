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
          end
        end

      end
    end
  end
end

