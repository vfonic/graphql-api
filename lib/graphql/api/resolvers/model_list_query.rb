module GraphQL::Api
  module Resolvers
    class ModelListQuery

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        if @model.respond_to?(:graph_where)
          @model.graph_where(args, ctx)
        else
          eager_load = []
          ctx.irep_node.children.each do |child|
            eager_load << child[0] if @model.reflections.find { |name, _| name == child[0] }
          end

          query_args = args.to_h
          query_args.delete('limit')

          q = @model.where(query_args)
          q.eager_load(*eager_load) if eager_load.any?
          q.limit(args[:limit] || 30)
        end
      end

    end
  end
end
