# frozen_string_literal: true

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

      def authorized?(action, ctx, instance, args)
        policy = get_policy(ctx)
        policy && check_auth?(action, policy, instance, args)
      end

      # rubocop:disable Metrics/MethodLength
      def check_auth?(action, policy, instance, args)
        case action
        when :create
          policy.create?(instance, args)
        when :update
          policy.update?(instance, args)
        when :destroy
          policy.destroy?(instance, args)
        when :read
          policy.read?(instance, args)
        else
          true
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
