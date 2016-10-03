module GraphQL::Api
  module Resolvers
    class QueryObjectQuery

      def initialize(query_object)
        @query_object = query_object
      end

      def call(obj, args, ctx)
        @query_object.new(args, ctx).execute
      end

    end
  end
end
