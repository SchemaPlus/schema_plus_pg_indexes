module SchemaPlusPgIndexes
  module ActiveRecord
    module ConnectionAdapters
      #
      # SchemaPlusPgIndexes extends the IndexDefinition object to return information
      # case sensitivity, expressions, and operator classes
      module IndexDefinition

        def case_sensitive?
          ActiveSupport::Deprecation.warn "ActiveRecord IndexDefinition#case_sensitive? is deprecated, used lower(column) or a citext type instead"
          true
        end

        def conditions
          ActiveSupport::Deprecation.warn "ActiveRecord IndexDefinition#conditions is deprecated, used #where instead"
          where
        end

        def kind
          ActiveSupport::Deprecation.warn "ActiveRecord IndexDefinition#kind is deprecated, used #using.to_s instead"
          using.to_s
        end

        def expression
          ActiveSupport::Deprecation.warn "ActiveRecord IndexDefinition#expressions is deprecated, simply define them in the column instead"
          nil
        end

        def operator_classes
          ActiveSupport::Deprecation.warn "ActiveRecord IndexDefinition#operator_classes is deprecated, use #opclasses instead"
          opclasses
        end
      end
    end
  end
end
