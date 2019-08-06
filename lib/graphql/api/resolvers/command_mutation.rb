# frozen_string_literal: true

require 'graphql/api/resolvers/helpers'

module GraphQL::Api
  module Resolvers
    class CommandMutation
      include Helpers

      def initialize(command, action)
        @model = command
        @action = action
      end

      def call(_obj, args, ctx)
        cmd = @model.new(args, ctx)

        policy = get_policy(ctx)
        return policy.unauthorized(@action, cmd, args) if policy && !policy.perform?(cmd, @action, args)

        cmd.send(@action)
      end
    end
  end
end
