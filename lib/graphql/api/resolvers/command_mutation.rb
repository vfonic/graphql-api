module GraphQL::Api
  module Resolvers
    class CommandMutation

      def initialize(command)
        @command = command
      end

      def call(inputs, ctx)
        @command.new(inputs, ctx).perform
      end

    end
  end
end
