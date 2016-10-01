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

  def schema_query(query, opts={})
    res = schema.execute(query)
    assert_nil res['errors'], res['errors']

    if opts[:print]
      puts res
    end
    res
  end

  # Models
  test "read blog" do
    schema_query("query { blog(id: #{Blog.first.id}) { id, name } }")
  end

  test "cannot read blog name" do
    data = schema_query("query { blog(id: #{Blog.first.id}) { id, name } }")
    assert_nil data['data']['blog']['name']
  end

  test "read multiple blogs" do
    schema_query("query { blogs { id, name, author { name } } }")
  end

  test "read multiple blogs limit" do
    schema_query("query { blogs(limit: 5) { id, name } }")
  end

  test "read multiple blogs with tags" do
    schema_query("query { blogs { id, name, tags { name } } }")
  end

  test "create a blog" do
    schema_query('mutation createBlog { createBlog(input: {name: "test", author_id: 2}) { blog { id } } }')
  end

  test "update a blog" do
    schema_query('mutation { updateBlog(input: {id: 1, name: "test"}) { blog { id } } }')
  end

  test "delete a blog" do
    schema_query('mutation { deleteBlog(input: {id: 1}) { blog_id } }')
  end

  # Commands
  test "mutation command" do
    schema_query('mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }')
  end

  test "mutation poro return" do
    schema_query('mutation { poroCommand(input: {name: "foobar"}) { poro { name } } }')
  end

  # Queries
  test "query blog return" do
    schema_query('query { blogQuery(content_matches: ["name"]) { id, name } }')
  end

end
