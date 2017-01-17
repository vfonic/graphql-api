module GraphQL::Api
  module Resolvers
    class CommandMutation

      def initialize(command, action)
        @command = command
        @action = action
      end

      def call(obj, args, ctx)
        @command.new(args, ctx).send(@action)
      end

    end
  end
end
