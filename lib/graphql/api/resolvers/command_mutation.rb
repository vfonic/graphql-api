module GraphQL::Api
  module Resolvers
    class CommandMutation

      def initialize(command, action)
        @command = command
        @action = action
      end

      def call(inputs, ctx)
        @command.new(inputs, ctx).send(@action)
      end

    end
  end
end
