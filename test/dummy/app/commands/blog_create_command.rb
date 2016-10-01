class BlogCreateCommand < Graphite::CommandType
  inputs name: :string, tags: [:string]
  returns :blog, Blog

  def perform
    blog = Blog.create!(name: inputs[:name], author_id: Author.first.id)
    (inputs[:tags] || []).each do |tag|
      t = Tag.find_or_create_by!(name: tag)
      blog.blog_tags.create!(tag_id: t.id)
    end

    blog
  end

end
