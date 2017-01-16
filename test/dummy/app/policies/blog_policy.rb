class BlogPolicy < GraphQL::Api::Policy

  def read?
    false
  end

end
