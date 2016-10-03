module GraphQL::Api
  module Resolvers
    class ModelCreateMutation

      def initialize(model)
        @model = model
      end

      def call(inputs, ctx)
        item = @model.create!(inputs.to_h)
        {@model.name.underscore.to_sym => item}
      end

    end
  end
end
