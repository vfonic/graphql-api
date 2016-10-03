class BlogCommand < GraphQL::Api::CommandType
  inputs name: :string, tags: [:string], id: :integer
  returns blog: Blog
  actions :update, :delete

  def update
    blog = Blog.find(inputs[:id])
    blog.update!(inputs.to_h)
    {blog: blog}
  end

  def delete
    blog = Blog.find(inputs[:id]).destroy!
    {blog: blog}
  end

end
