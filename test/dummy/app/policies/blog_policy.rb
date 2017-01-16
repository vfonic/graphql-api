class BlogPolicy < GraphQL::Api::Policy

  def read?
    true
  end

end
