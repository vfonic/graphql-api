require 'test_helper'

class Graphite::Test < ActiveSupport::TestCase

  def schema
    Graphite::Schema.new.schema
  end

  setup do
    (1..20).each do
      author = Author.create!(name: 'test')
      blog = Blog.create!(name: 'test', content: 'foobar', author: author)
      tag = Tag.create!(name: 'testing')
      BlogTag.create!(blog: blog, tag: tag)

      tag = Tag.create!(name: 'testing2')
      BlogTag.create!(blog: blog, tag: tag)
    end
  end

  # Models
  test "read blog" do
    schema.execute("query { blog(id: #{Blog.first.id}) { id, name } }")
  end

  test "read multiple blogs" do
    schema.execute("query { blogs { id, name, author { name } } }")
  end

  test "read multiple blogs limit" do
    schema.execute("query { blogs(limit: 5) { id, name } }")
  end

  test "read multiple blogs with tags" do
    schema.execute("query { blogs { id, name, tags { name } } }")
  end

  test "create a blog" do
    schema.execute('mutation createBlog { createBlog(input: {name: "test", author_id: 2}) { blog { id } } }')
  end

  test "update a blog" do
    schema.execute('mutation { updateBlog(input: {id: 1, name: "test"}) { blog { id } } }')
  end

  test "delete a blog" do
    schema.execute('mutation { deleteBlog(input: {id: 1}) { blog_id } }')
  end

  # Commands
  test "mutation command" do
    schema.execute('mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }')
  end

  test "query" do

  end

end
