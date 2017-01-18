require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelFindQuery
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        params = args.to_h
        instance = @model.find_by!(params)

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(:read, instance, params) unless policy.read?(instance, params)
        end

        instance
      end

    end
  end
end
