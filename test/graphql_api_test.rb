require 'test_helper'

class GraphQL::Api::Test < ActiveSupport::TestCase

  def schema
    GraphQL::Api::Schema.new.schema
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
    res = schema.execute(query, context: opts[:context])

    if opts[:should_fail]
      assert_not_nil res['errors'], res
    else
      assert_nil res['errors'], res['errors']
    end

    if opts[:print]
      puts res
    end
    res
  end

  # Models
  test "read blog" do
    schema_query("query { blog(id: #{Blog.first.id}) { id, name } }")
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
    schema_query('mutation { createBlog(input: {name: "test", content: "hello", author_id: 2}) { blog { id, name, content } } }', print: true)
  end

  test "update a blog" do
    schema_query('mutation { updateBlog(input: {id: 1, name: "test"}) { blog { id } } }')
  end

  test "delete a blog" do
    schema_query('mutation { deleteBlog(input: {id: 1}) { blog { id } } }')
  end

  # Commands
  test "mutation command" do
    schema_query('mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }')
  end

  test "mutation poro return" do
    schema_query('mutation { poroCommand(input: {name: "foobar"}) { poro { name } } }')
  end

  test "mutation custom action command update" do
    schema_query('mutation { updateBlogCommand(input: {name: "foobar", id: 1}) { blog { name } } }')
  end

  test "mutation custom action command delete" do
    schema_query('mutation { deleteBlogCommand(input: {id: 3}) { blog { id } } }')
  end

  # Queries
  test "query blog failing input" do
    schema_query('query { blogQuery(content_matches: ["name"]) { id, name } }', should_fail: true)
  end

  test "query blog" do
    schema_query('query { blogQuery(reqs: "required") { id, name } }')
  end


  test "custom mutation" do
    simple_mutation = GraphQL::Relay::Mutation.define do
      input_field :name, !types.String
      return_field :item, types.String
      resolve -> (obj, args, ctx) {  {item: 'hello'}  }
    end

    graphite = GraphQL::Api.graph
    mutation = graphite.mutation do
      field 'simpleMutation', simple_mutation.field
    end

    schema = GraphQL::Schema.define(query: graphite.query, mutation: mutation)
    schema.execute('mutation { simpleMutation(input: {name: "hello"}) { item } }')
  end

  # policy objects
  test "policy object read failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query("query { blogs { id, name, tags { name } } }", context: { test_key: 1 })
    end
  end

  test "policy object create failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('mutation { createBlog(input: {name: "test", author_id: 2}) { blog { id } } }', context: { test_key: 1 })
    end
  end

  test "policy object update failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('mutation { updateBlog(input: {id: 1, name: "test"}) { blog { id } } }', context: { test_key: 1 })
    end
  end

  test "policy object delete failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('mutation { deleteBlog(input: {id: 1}) { blog { id } } }', context: { test_key: 1 })
    end
  end

  test "cannot read blog name" do
    data = schema_query("query { blog(id: #{Blog.first.id}) { id, name } }")
    assert_nil data['data']['blog']['name']
  end

end
