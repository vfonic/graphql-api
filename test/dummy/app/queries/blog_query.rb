class BlogQuery < Graphite::QueryType
  arguments name: :string, content_matches: [:string]
  return_type [Blog]

  def execute
    Blog.all
  end

end
