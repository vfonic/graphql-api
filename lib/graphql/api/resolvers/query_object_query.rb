require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class QueryObjectQuery
      include Helpers

      def initialize(query_object, action)
        @model = query_object
        @action = action
      end

      def call(obj, args, ctx)
        params = args.to_h
        query = @model.new(args, ctx)

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(@action, query, params) unless policy.execute?(query, @action, params)
        end

        query.send(@action)
      end

    end
  end
end
