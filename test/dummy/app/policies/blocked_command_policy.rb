class BlockedCommandPolicy < GraphQL::Api::Policy

  def perform?(*)
    false
  end

end
