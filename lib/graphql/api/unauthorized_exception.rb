# frozen_string_literal: true

module GraphQL::Api
  class UnauthorizedException < StandardError
    attr_accessor :user, :action, :instance, :params

    def initialize(user = nil, action = nil, instance = nil, params = nil)
      @action = action
      @instance = instance
      @params = params
      @user = user
      super("Cannot #{action} #{instance.class}")
    end

    def as_json
      {
        action: action,
        object: instance.class.name
      }
    end
  end
end
