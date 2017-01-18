class BlockedQuery < GraphQL::Api::QueryType
  arguments name: :string
  return_type [Blog]

  def execute
    Blog.all
  end

end
