module SchemaPlusPgIndexes
  module ActiveRecord
    module ConnectionAdapters
      #
      # SchemaPlusPgIndexes extends the IndexDefinition object to return information
      # case sensitivity, expressions, and operator classes
      module IndexDefinition

        attr_accessor :expression
        attr_accessor :operator_classes

        def case_sensitive?
          @case_sensitive
        end

        def conditions
          ActiveSupport::Deprecation.warn "ActiveRecord IndexDefinition#conditions is deprecated, used #where instead"
          where
        end

        def kind
          ActiveSupport::Deprecation.warn "ActiveRecord IndexDefinition#kind is deprecated, used #using.to_s instead"
          using.to_s
        end

        def initialize(*args)
          super
          options = args.dup.extract_options!
          @expression = options[:expression]
          @operator_classes = options[:operator_classes] || {}
          @case_sensitive = options.include?(:case_sensitive) ? options[:case_sensitive] : true
        end

        def ==(other)
          return false if not super other
          return false unless self.expression == other.expression
          return false unless !!self.case_sensitive? == !!other.case_sensitive?
          return false unless self.operator_classes == other.operator_classes
          return true
        end

      end
    end
  end
end
