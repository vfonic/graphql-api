module GraphQL::Api
  module Resolvers
    class ModelFindQuery

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        if @model.respond_to?(:graph_find)
          @model.graph_find(args, ctx)
        else
          @model.find_by!(args.to_h)
        end
      end

    end
  end
end
