module GraphQL::Api
  module Resolvers
    module Helpers

      def key
        @key ||= @model.name.underscore.to_sym
      end

      def policy_class
        @policy_class ||= "#{@model.name}Policy".safe_constantize
      end

      def get_policy(ctx)
        return ctx[:policy][key] if ctx[:policy] && ctx[:policy][key]

        if policy_class
          policy = @policy_class.new(ctx)
          ctx[:policy] ||= {}
          ctx[:policy][key] = policy
          return policy
        end

        false
      end

    end
  end
end
