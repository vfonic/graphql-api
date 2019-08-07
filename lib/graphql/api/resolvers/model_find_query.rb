# frozen_string_literal: true

module GraphQL::Api
  module Resolvers
    class ModelFindQuery
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(_obj, args, ctx)
        instance = @model.find_by!(args.to_h)

        policy = get_policy(ctx)
        return policy.unauthorized(:read, instance, args) if policy && !policy.read?(instance, args)

        instance
      end
    end
  end
end
