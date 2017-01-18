module GraphQL::Api
  module Resolvers
    class ModelListQuery

      def initialize(model)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(obj, args, ctx)
        eager_load = []
        ctx.irep_node.children.each do |child|
          eager_load << child[0] if @model.reflections.find { |name, _| name == child[0] }
        end

        query_args = args.to_h

        results = @model.where(query_args)
        results = results.eager_load(*eager_load) if eager_load.any?

        if @policy_class
          policy = @policy_class.new(ctx)
          results.each do |instance|
            return policy.unauthorized! unless policy.read?(instance, query_args)
          end
        end

        results
      end

    end
  end
end
