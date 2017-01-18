module GraphQL::Api
  module Resolvers
    class Field

      def initialize(model, name)
        @model = model
        @name = name
        @policy_class = "#{model.name}Policy".safe_constantize
      end

      def call(obj, args, ctx)
        params = args.to_h

        if @policy_class
          policy = @policy_class.new(ctx)

          unless policy.read?(obj, params)
            return policy.unauthorized!
          end

          unless policy.access_field?(obj, @name)
            return policy.unauthorized_field_access(@name)
          end
        end

        obj.send(@name)
      end

    end
  end
end
