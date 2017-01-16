class BlogPolicy < GraphQL::Api::Policy

  def read?
    ctx[:test_key].nil?
  end

end
