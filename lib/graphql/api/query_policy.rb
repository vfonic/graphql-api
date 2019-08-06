# frozen_string_literal: true

require 'graphql/api/unauthorized_exception'

module GraphQL::Api
  class QueryPolicy
    attr_reader :ctx

    def initialize(ctx)
      @ctx = ctx
    end

    def user
      ctx[:current_user]
    end

    def execute?(_cmd, _action, _params)
      true
    end

    def unauthorized(action, instance, params)
      raise UnauthorizedException.new(user, action, instance, params)
    end

    def unauthorized_field_access(_field_name, _instance, _params)
      nil
    end
  end
end
