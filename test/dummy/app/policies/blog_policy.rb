class BlogPolicy < GraphQL::Api::Policy

  def read?
    ctx[:test_key].nil?
  end

  def destroy?
    ctx[:test_key].nil?
  end

  def create?
    ctx[:test_key].nil?
  end

  def update?
    ctx[:test_key].nil?
  end

  def access_name?
    false
  end

end
