module GraphQL::Api
  module Resolvers
    class ModelUpdateMutation

      def initialize(model)
        @model = model
      end

      def call(inputs, ctx)
        item = @model.find(inputs[:id])
        item.update!(inputs.to_h)
        {@model.name.underscore.to_sym => item}
      end

    end
  end
end
