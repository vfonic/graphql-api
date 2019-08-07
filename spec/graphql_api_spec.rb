# frozen_string_literal: true

# rubocop:disable RSpec/FilePath
require 'rails_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe GraphQL::Api do
  def schema_query(query, opts = { context: { current_user: 'user' } })
    result = GraphQL::Api.schema.execute(query, opts.slice(:context))

    if opts[:should_fail]
      expect(result['errors']).to be_present
    else
      expect(result['errors']).to be nil
    end

    result
  end

  let(:blog) { create(:blog) }
  let(:author) { create(:author) }

  # Models
  it 'read blog' do
    result = schema_query(%{
      query {
        blog(id: #{blog.id}) {
          id
          content
        }
      }
    })

    expect(result.dig('data', 'blog')).to eq('id' => blog.id, 'content' => blog.content)
  end

  it 'read multiple blogs' do
    create_list(:blog, 2)

    result = schema_query(%{
      query {
        blogs {
          id
          content
        }
      }
    })

    expect(result.dig('data', 'blogs').size).to eq(2)
  end

  it 'read multiple blogs with tags' do
    common_tag = create(:tag)
    create(:blog, tags: [create(:tag), common_tag])
    create(:blog, tags: [create(:tag), common_tag])

    result = schema_query(%{
      query {
        blogs {
          id
          content
          tags {
            name
          }
        }
      }
    })

    blogs = result.dig('data', 'blogs')
    expect(blogs.size).to eq(2)
    blogs.each do |blog|
      expect(blog['tags'].size).to eq(2)
    end
  end

  it 'create a blog' do
    result = schema_query(%{
      mutation {
        createBlog(input: {
          name: "test",
          content: "hello",
          author_id: #{author.id}
        }) {
          blog {
            id
            content
            author {
              name
            }
          }
        }
      }
    })

    expect(result.dig('data', 'createBlog', 'blog', 'author', 'name')).to eq(author.name)
  end

  it 'update a blog' do
    result = schema_query(%{
      mutation {
        updateBlog(input: {
          id: #{blog.id}
          content: "new content"
        }) {
          blog {
            id
            content
          }
        }
      }
    })

    expect(result.dig('data', 'updateBlog', 'blog', 'content')).to eq('new content')
  end

  it 'delete a blog' do
    blog = create(:blog)

    expect do
      schema_query(%{
        mutation {
          deleteBlog(input: {
            id: #{blog.id}
          }) {
            blog {
              id
            }
          }
        }
      })
    end.to change(Blog, :count).by(-1)
  end

  # Commands
  it 'mutation command' do
    result = schema_query(%{
      mutation {
        blogCreateCommand(input: {
          tags: ["test", "testing"],
          name: "hello"
          author_id: #{author.id}
        }) {
          blog {
            id
            tags {
              name
            }
          }
        }
      }
    })

    expect(result.dig('data', 'blogCreateCommand', 'blog', 'tags').size).to eq(2)
  end

  it 'mutation poro return' do
    result = schema_query(%{
      mutation {
        poroCommand(input: {
          name: "foobar"
        }) {
          poro {
            name
          }
        }
      }
    })

    expect(result.dig('data', 'poroCommand', 'poro', 'name')).to eq('foobar')
  end

  it 'mutation custom action command update' do
    result = schema_query(%{
      mutation {
        updateBlogCommand(input: {
          id: #{blog.id}
          content: "foobar"
        }) {
          blog {
            content
          }
        }
      }
    })

    expect(result.dig('data', 'updateBlogCommand', 'blog', 'content')).to eq('foobar')
  end

  it 'mutation custom action command delete' do
    blog = create(:blog)

    expect do
      schema_query(%{
        mutation {
          deleteBlogCommand(input: {
            id: #{blog.id}
          }) {
            blog {
              id
            }
          }
        }
      })
    end.to change(Blog, :count).by(-1)
  end

  # Queries
  it 'query blog failing input' do
    result = schema_query(%{
      query {
        blogQuery(content_matches: ["name"]) {
          id
          name
        }
      }
    }, should_fail: true)

    expect(result.dig('errors', 0, 'message')).to eq("Field 'blogQuery' is missing required arguments: reqs")
  end

  it 'query blogs multiple' do
    result = schema_query(%{
      query {
        blogQuery(reqs: "required") {
          id
          content
        }
        blogs {
          id
          content
        }
        blog(id: #{blog.id}) {
          id
          content
        }
      }
    })

    expect(result['data'].keys).to match_array(%w[blogQuery blogs blog])
  end

  it 'query blog secondary' do
    blog = create(:blog)

    result = schema_query(%{
      query {
        secondaryBlogQuery(reqs: "required") {
          id
          content
        }
      }
    })

    expect(result.dig('data', 'secondaryBlogQuery', 'content')).to eq(blog.content)
  end

  it 'custom mutation' do
    simple_mutation = GraphQL::Relay::Mutation.define do
      input_field :name, !types.String
      return_field :item, types.String
      resolve ->(_obj, _args, _ctx) { { item: 'hello' } }
    end

    config = GraphQL::Api::Configure.new
    mutation = config.graphql_mutation do
      field 'simpleMutation', simple_mutation.field
    end

    schema = GraphQL::Schema.define(query: config.graphql_query, mutation: mutation)
    schema.execute(%{
      mutation {
        simpleMutation(input: {
          name: "hello"
        }) {
          item
        }
      }
    })
  end

  # policy objects
  xit 'policy object read failing' do
    expect do
      schema_query(%{
        query {
          blogs {
            id
            content
            tags {
              name
            }
          }
        }
      }, context: { current_user: nil })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  xit 'policy object create failing' do
    expect do
      schema_query(%{
        mutation {
          createBlog(input: {
            name: "test",
            author_id: #{author.id}
          }) {
            blog {
              id
            }
          }
        }
      }, context: { test_key: blog.id })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it 'policy object update failing' do
    expect do
      schema_query(%{
        mutation {
          updateBlog(input: {
            id: #{blog.id},
            name: "test"
          }) {
            blog {
              id
            }
          }
        }
      }, context: { test_key: blog.id })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it 'policy object delete failing' do
    expect do
      schema_query(%{
        mutation {
          deleteBlog(input: {
            id: #{blog.id}
          }) {
            blog {
              id
            }
          }
        }
      }, context: { test_key: blog.id })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it 'policy object query unauthorized' do
    expect do
      schema_query(%{
        query {
          blockedQuery() {
            id
          }
        }
      })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it 'policy object command unauthorized' do
    expect do
      schema_query(%{
        mutation {
          blockedCommand(input: {
            name: "foobar"
          }) {
            poro {
              name
            }
          }
        }
      })
    end.to raise_error GraphQL::Api::UnauthorizedException
  end

  it 'cannot read blog name' do
    data = schema_query(%{
      query {
        blog(id: #{blog.id}) {
          id
          name
        }
      }
    })
    assert_nil data['data']['blog']['name']
  end
end
# rubocop:enable RSpec/ExampleLength
# rubocop:enable RSpec/FilePath
