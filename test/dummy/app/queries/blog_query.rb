class BlogQuery < GraphQL::Api::QueryType
  arguments name: :string, content_matches: [:string], reqs: :string!
  return_type [Blog]

  def execute
    Blog.all
  end

end
