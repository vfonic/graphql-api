class BlockedQueryPolicy < GraphQL::Api::Policy

  def execute?(*)
    false
  end

end
