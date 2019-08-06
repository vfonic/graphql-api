# frozen_string_literal: true

require 'graphql/api/resolvers/helpers'

module GraphQL::Api
  module Resolvers
    class ModelUpdateMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(_obj, args, ctx)
        instance = @model.find(args[:id])

        policy = get_policy(ctx)
        return policy.unauthorized(:update, instance, args) if policy && !policy.update?(instance, args)

        instance.update!(args.to_h)
        { key => instance }
      end
    end
  end
end
