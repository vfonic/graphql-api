module GraphQL::Api
  module Resolvers
    class ModelFindQuery

      def initialize(model)
        @model = model
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(obj, args, ctx)
        params = args.to_h
        instance = @model.find_by!(params)

        if @policy_class
          policy = @policy_class.new(ctx)
          return policy.unauthorized! unless policy.read?(instance, params)
        end

        instance
      end

    end
  end
end
