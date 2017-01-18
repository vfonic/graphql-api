require "graphql/api/unauthorized_exception"

module GraphQL::Api
  class Policy
    attr_reader :ctx

    def initialize(ctx)
      @ctx = ctx
    end

    def user
      ctx[:current_user]
    end

    def allowed_params(action)
    end

    def create?(model, params)
      true
    end

    def update?(model, params)
      true
    end

    def destroy?(model, params)
      true
    end

    def read?(model, params)
      true
    end

    def access_field?(model, field)
      true
    end

    def unauthorized!
      raise UnauthorizedException.new
    end

    def unauthorized_field_access(field_name)
      nil
    end

  end
end
