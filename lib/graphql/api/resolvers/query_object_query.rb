module GraphQL::Api
  module Resolvers
    class QueryObjectQuery

      def initialize(query_object)
        @query_object = query_object
      end

      def call(obj, args, ctx)
        params = args.to_h
        @query_object.new(params, ctx).execute
      end

    end
  end
end
