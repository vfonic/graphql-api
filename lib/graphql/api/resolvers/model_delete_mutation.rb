require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelDeleteMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        instance = @model.find(args[:id])
        params = args.to_h

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(:destroy, instance, params) unless policy.destroy?(instance, params)
        end

        instance.destroy!
        {key => instance}
      end

    end
  end
end
