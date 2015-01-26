module SchemaPlusPgIndexes
  module Middleware
    module Migration

      def self.insert
        SchemaMonkey::Middleware::Migration::Index.prepend DeprecateArgs
      end

      class DeprecateArgs < SchemaMonkey::Middleware::Base
        def call(env)
          {:conditions => :where, :kind => :using}.each do |deprecated, proper|
            if env.options[deprecated]
              ActiveSupport::Deprecation.warn "ActiveRecord index option #{deprecated.inspect} is deprecated, use #{proper.inspect} instead"
              env.options[proper] = env.options.delete(deprecated)
            end
          end
          continue env
        end
      end

    end
  end
end
