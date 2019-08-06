# frozen_string_literal: true

class BlockedCommandPolicy < GraphQL::Api::CommandPolicy
  def perform?(*)
    false
  end
end
