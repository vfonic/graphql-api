module GraphQL::Api
  module Resolvers
    class ModelCreateMutation

      def initialize(model, policy=nil)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(obj, args, ctx)
        if @policy_class
          policy = @policy_class.new(ctx, nil)
          return policy.unauthorized! unless policy.create?
        end

        item = @model.create!(args.to_h)
        {key => item}
      end

      def key
        @model.name.underscore.to_sym
      end

    end
  end
end
