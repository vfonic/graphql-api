module GraphQL::Api
  module Resolvers
    class ModelCreateMutation

      def initialize(model)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(obj, args, ctx)
        params = args.to_h # ensure to_h is called as args is not a hash
        instance = @model.new(params)

        if @policy_class
          policy = @policy_class.new(ctx)
          return policy.unauthorized! unless policy.create?(instance, params)
        end

        item = instance.save!
        {key => item}
      end

      def key
        @model.name.underscore.to_sym
      end

    end
  end
end
