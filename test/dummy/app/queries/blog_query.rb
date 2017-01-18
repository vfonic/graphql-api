class BlogQuery < GraphQL::Api::QueryType
  action :execute, returns: [Blog], args: {name: :string, content_matches: [:string], reqs: :string!}

  def execute
    Blog.all
  end

end
