# frozen_string_literal: true

module GraphQL::Api
  module Resolvers
    class ModelDeleteMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(_obj, args, ctx)
        instance = @model.find(args[:id])

        policy = get_policy(ctx)
        return policy.unauthorized(:create, instance, args) if policy && !policy.destroy?(instance, args)

        instance.destroy!
        { key => instance }
      end
    end
  end
end
