require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelListQuery
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        eager_load = []
        ctx.irep_node.children.each do |child|
          eager_load << child[0] if @model.reflections.find { |name, _| name == child[0] }
        end

        query_args = args.to_h

        results = @model.where(query_args)
        results = results.eager_load(*eager_load) if eager_load.any?

        policy = get_policy(ctx)
        if policy
          # todo: is there a more efficient way of handling this? or should you be able to skip it?
          results.each do |instance|
            return policy.unauthorized! unless policy.read?(instance, query_args)
          end
        end

        results
      end

    end
  end
end
