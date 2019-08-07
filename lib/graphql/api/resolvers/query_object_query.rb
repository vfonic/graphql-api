# frozen_string_literal: true

module GraphQL::Api
  module Resolvers
    class QueryObjectQuery
      include Helpers

      def initialize(query_object, action)
        @model = query_object
        @action = action
      end

      def call(_obj, args, ctx)
        query = @model.new(args, ctx)

        policy = get_policy(ctx)
        return policy.unauthorized(@action, query, args) if policy && !policy.execute?(query, @action, args)

        query.send(@action)
      end
    end
  end
end
