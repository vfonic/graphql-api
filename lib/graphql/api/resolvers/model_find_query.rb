module GraphQL::Api
  module Resolvers
    class ModelFindQuery

      def initialize(model)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(obj, args, ctx)
        if @model.respond_to?(:graph_find)
          item = @model.graph_find(args, ctx)
        else
          item = @model.find_by!(args.to_h)
        end

        if @policy_class
          policy = @policy_class.new(ctx, item)
          return policy.unauthorized! unless policy.read?
        end

        item
      end

    end
  end
end
