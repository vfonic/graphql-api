require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelUpdateMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        instance = @model.find(args[:id])
        params = args.to_h

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(:update, instance, params) unless policy.update?(instance, params)
        end

        instance.update!(params)
        {key => instance}
      end

    end
  end
end
