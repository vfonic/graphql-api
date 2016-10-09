module GraphQL::Api
  module Resolvers
    class ModelCreateMutation

      def initialize(model, policy=nil)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(inputs, ctx)
        if @policy_class
          policy = @policy_class.new(ctx[:current_user], nil, ctx)
          unless policy.create?
            return {key => nil}
          end
        end

        item = @model.create!(inputs.to_h)
        {key => item}
      end

      def key
        @model.name.underscore.to_sym
      end

    end
  end
end
