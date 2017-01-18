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

    # def execute?(command, action)
    # end
    #
    # def query?(query, params)
    # end

    def create?(instance, params)
      true
    end

    def update?(instance, params)
      true
    end

    def destroy?(instance, params)
      true
    end

    def read?(instance, params)
      true
    end

    def access_field?(instance, field)
      true
    end

    def unauthorized(action, instance, params)
      raise UnauthorizedException.new(user, action, instance, params)
    end

    def unauthorized_field_access(field_name)
      nil
    end

  end
end
