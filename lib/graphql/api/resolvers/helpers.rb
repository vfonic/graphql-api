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
        return ctx[:policy] if ctx[:policy]

        if policy_class
          policy = @policy_class.new(ctx)
          ctx[:policy] = policy
          return policy
        end

        false
      end

    end
  end
end
