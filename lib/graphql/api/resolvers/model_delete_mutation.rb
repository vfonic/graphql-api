module GraphQL::Api
  module Resolvers
    class ModelDeleteMutation

      def initialize(model)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(inputs, ctx)
        item = @model.find(inputs[:id])

        if @policy_class
          policy = @policy_class.new(ctx, item)
          return policy.unauthorized! unless policy.destroy?
        end

        item.destroy!
        {key => item}
      end

      def key
        @model.name.underscore.to_sym
      end

    end
  end
end
