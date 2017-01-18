require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class CommandMutation
      include Helpers

      def initialize(command, action)
        @model = command
        @action = action
      end

      def call(obj, args, ctx)
        params = args.to_h
        cmd = @model.new(args, ctx)

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(@action, cmd, params) unless policy.perform?(cmd, @action, params)
        end

        cmd.send(@action)
      end

    end
  end
end
