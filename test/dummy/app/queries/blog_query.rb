class BlogQuery < Graphite::QueryType
  arguments name: :string
  fields blog: Blog

end