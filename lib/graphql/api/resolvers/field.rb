module GraphQL::Api
  module Resolvers
    class Field

      def initialize(model, name)
        @model = model
        @name = name
      end

      def call(obj, args, ctx)
        if obj.respond_to?("access_#{@name}?")
          obj.send(@name) if obj.send("access_#{@name}?", ctx)
        else
          obj.send(@name)
        end
      end

    end
  end
end
