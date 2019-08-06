require 'rails_helper'

RSpec.describe GraphQL::Api do
  def schema_query(query, opts={})
    res = GraphQL::Api.schema.execute(query, context: opts[:context])

    if opts[:should_fail]
      expect(res['errors']).to be_present
    else
      expect(res['errors']).to be nil
    end

    if opts[:print]
      puts res
    end
    res
  end

  let(:blog) { create(:blog) }
  let(:author) { create(:author) }

  # Models
  it "read blog" do
    schema_query("query { blog(id: #{blog.id}) { id, name } }")
  end

  it "read multiple blogs" do
    schema_query("query { blogs { id, name } }")
  end

  it "read multiple blogs with tags" do
    schema_query("query { blogs { id, name, tags { name } } }")
  end

  it "create a blog" do
    res = schema_query(%{mutation { createBlog(input: {name: "test", content: "hello", author_id: #{author.id}}) { blog { id, name, content } } }})
    expect(res['data']['createBlog']['blog']['content']).to be_present
  end

  it "update a blog" do
    schema_query(%{mutation { updateBlog(input: {id: #{blog.id}, name: "test"}) { blog { id } } }})
  end

  it "delete a blog" do
    schema_query("mutation { deleteBlog(input: {id: #{blog.id}}) { blog { id } } }")
  end

  # Commands
  xit "mutation command" do
    schema_query('mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }')
  end

  it "mutation poro return" do
    schema_query('mutation { poroCommand(input: {name: "foobar"}) { poro { name } } }')
  end

  it "mutation custom action command update" do
    schema_query(%{mutation { updateBlogCommand(input: {name: "foobar", id: #{blog.id}}) { blog { name } } }})
  end

  it "mutation custom action command delete" do
    schema_query("mutation { deleteBlogCommand(input: {id: #{blog.id}}) { blog { id } } }")
  end

  # Queries
  it "query blog failing input" do
    schema_query('query { blogQuery(content_matches: ["name"]) { id, name } }', should_fail: true)
  end

  it "query blogs multiple" do
    schema_query(%{
      query { blogQuery(reqs:"required") { id, name } }
      query { blogs() { id, name } }
      query { blog(id: #{blog.id}) { id, name, content } }
    })
  end

  xit "query blog secondary" do
    schema_query('query { secondaryBlogQuery(reqs: "required") { id, name } }')
  end

  it "custom mutation" do
    simple_mutation = GraphQL::Relay::Mutation.define do
      input_field :name, !types.String
      return_field :item, types.String
      resolve -> (obj, args, ctx) {  {item: 'hello'}  }
    end

    config = GraphQL::Api::Configure.new
    mutation = config.graphql_mutation do
      field 'simpleMutation', simple_mutation.field
    end

    schema = GraphQL::Schema.define(query: config.graphql_query, mutation: mutation)
    schema.execute('mutation { simpleMutation(input: {name: "hello"}) { item } }')
  end

  # policy objects
  it "policy object read failing" do
    expect do
      schema_query("query { blogs { id, name, tags { name } } }", context: { test_key: blog.id })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it "policy object create failing" do
    expect do
      schema_query('mutation { createBlog(input: {name: "test", author_id: 2}) { blog { id } } }', context: { test_key: blog.id })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it "policy object update failing" do
    expect do
      schema_query(%{mutation { updateBlog(input: {id: #{blog.id}, name: "test"}) { blog { id } } }}, context: { test_key: blog.id })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it "policy object delete failing" do
    expect do
      schema_query(%{mutation { deleteBlog(input: {id: #{blog.id}}) { blog { id } } }}, context: { test_key: blog.id })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it "policy object query unauthorized" do
    expect do
      schema_query('query { blockedQuery() { id } }')
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it "policy object command unauthorized" do
    expect do
      schema_query('mutation { blockedCommand(input: {name: "foobar"}) { poro { name } } }')
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it "cannot read blog name" do
    data = schema_query("query { blog(id: #{blog.id}) { id, name } }")
    assert_nil data['data']['blog']['name']
  end

end
