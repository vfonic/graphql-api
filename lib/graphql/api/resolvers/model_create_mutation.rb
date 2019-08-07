# frozen_string_literal: true

module GraphQL::Api
  module Resolvers
    class ModelCreateMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(_obj, args, ctx)
        instance = @model.new(args.to_h)

        policy = get_policy(ctx)
        return policy.unauthorized(:create, instance, args) if policy && !policy.create?(instance, args)

        instance.save!
        { key => instance }
      end
    end
  end
end
