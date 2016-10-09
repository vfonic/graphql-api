require "graphql/api/unauthorized_exception"

module GraphQL::Api
  class Policy
    attr_reader :ctx, :model

    def initialize(ctx, model)
      @model = model
      @ctx = ctx
    end

    def user
      ctx[:current_user]
    end

    def create?
      true
    end

    def update?
      true
    end

    def destroy?
      true
    end

    def read?
      true
    end

    def unauthorized!(msg=nil)
      raise UnauthorizedException.new(msg)
    end

  end
end
