# frozen_string_literal: true

class BlockedQueryPolicy < GraphQL::Api::QueryPolicy
  def execute?(*)
    false
  end
end
