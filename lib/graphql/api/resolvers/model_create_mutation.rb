require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelCreateMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        params = args.to_h # ensure to_h is called as args is not a hash
        instance = @model.new(params)

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(:create, instance, params) unless policy.create?(instance, params)
        end

        instance.save!
        {key => instance}
      end

    end
  end
end
