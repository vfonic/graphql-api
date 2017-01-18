module GraphQL::Api
  module Resolvers
    class ModelUpdateMutation

      def initialize(model)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(obj, args, ctx)
        instance = @model.find(args[:id])
        params = args.to_h

        if @policy_class
          policy = @policy_class.new(ctx)
          return policy.unauthorized! unless policy.update?(instance, params)
        end

        instance.update!(params)
        {key => instance}
      end

      def key
        @model.name.underscore.to_sym
      end

    end
  end
end
