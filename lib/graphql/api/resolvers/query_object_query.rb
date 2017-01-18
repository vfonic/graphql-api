require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class QueryObjectQuery
      include Helpers

      def initialize(query_object)
        @model = query_object
      end

      def call(obj, args, ctx)
        params = args.to_h
        query = @model.new(args, ctx)

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(:execute, cmd, params) unless policy.execute?(query, params)
        end

        query.execute
      end

    end
  end
end
