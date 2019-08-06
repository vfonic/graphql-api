# frozen_string_literal: true

require 'graphql/api/unauthorized_exception'

module GraphQL::Api
  class Policy
    attr_reader :ctx

    def initialize(ctx)
      @ctx = ctx
    end

    def user
      ctx[:current_user]
    end

    def create?(_instance, _args)
      true
    end

    def update?(_instance, _params)
      true
    end

    def destroy?(_instance, _params)
      true
    end

    def read?(_instance, _params)
      true
    end

    def access_field?(_instance, _field)
      true
    end

    def unauthorized(action, instance, params)
      raise UnauthorizedException.new(user, action, instance, params)
    end

    def unauthorized_field_access(_field_name, _instance, _params)
      # raise UnauthorizedException.new(user, "read.#{field_name}", instance, params)
      nil
    end
  end
end
