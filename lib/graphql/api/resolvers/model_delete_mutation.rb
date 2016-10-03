module GraphQL::Api
  module Resolvers
    class ModelDeleteMutation

      def initialize(model)
        @model = model
      end

      def call(inputs, ctx)
        item = @model.find(inputs[:id])
        item.destroy!
        {"#{@model.name.underscore.to_sym}_id".to_sym => inputs[:id]}
      end

    end
  end
end
