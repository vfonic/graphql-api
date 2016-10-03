# GraphQL-Api
GraphQL-Api is an opinionated Graphql framework for Rails that supports 
auto generating queries based on Active Record models and plain Ruby 
objects.

## Example

Given the following model structure:

```ruby
class Author < ActiveRecord::Base
  has_many :blogs
  # columns: name
end

class Blog < ActiveRecord::Base
  belongs_to :author
  # columns: title, content
end
```

GraphQL-Api will respond to the following queries for the blog resource:

```graphql
query { blog(id: 1) { id, title, author { name } } }

query { blogs(limit: 5) { id, title, author { name } } }

mutation { createBlog(input: {name: "test", author_id: 2}) { blog { id } } }

mutation { updateBlog(input: {id: 1, title: "test"}) { blog { id } } }

mutation { deleteBlog(input: {id: 1}) { blog_id } }
```

GraphQL-Api also has support for command objects:
```ruby
# Graphql mutation derived from the below command object:
# mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }

class BlogCreateCommand < GraphQL::Api::CommandType
  inputs name: :string, tags: [:string]
  returns blog: Blog

  def perform
    # do something here to add some tags to a blog, you could also use ctx[:current_user] to access the user
    {blog: blog}
  end

end
```

... and query objects:
```ruby
# Graphql query derived from the below query object:
# query { blogQuery(content_matches: ["name"]) { id, name } }

class BlogQuery < GraphQL::Api::QueryType
  arguments name: :string, content_matches: [:string]
  return_type [Blog]

  def execute
    Blog.all
  end

end
```

## Contents

1. [Guides](#guides)
2. [Documentation](#documentation)
3. [Roadmap](#roadmap)

## Guides

### Endpoint

Creating an endpoint for GraphQL-Api.

```ruby
# inside an initializer or other file inside the load path
GraphSchema = GraphQL::Api::Schema.new.schema

# controllers/graphql_controller.rb
class GraphqlController < ApplicationController

  # needed by the relay framework, defines the graphql schema
  def index
    render json: GraphSchema.execute(GraphQL::Introspection::INTROSPECTION_QUERY)
  end

  # will respond to graphql requests and pass through the current user
  def create
    render json: GraphSchema.execute(
        params[:query], 
        variables: params[:variables] || {}, 
        context: {current_user: current_user}
    )
  end
  
end
```

### Authorization

GraphQL-Api will check for an `access_<field>?(ctx)` method on all model 
objects before returning the  value. If this method returns false, the 
value will be `nil`.

To scope queries for the model, define the `graph_find(args, ctx)` and 
`graph_where(args, ctx)` methods using the `ctx` parameter to get the
current user and apply a scoped query. For example:

```ruby
class Blog < ActiveRecord::Base
  belongs_to :author
  
  def self.graph_find(args, ctx)
    ctx[:current_user].blogs.find(args[:id])
  end
  
  def access_content?(ctx)
    ctx[:current_user].is_admin?
  end
  
end
```

For more complicated access management, define query objects and Poro's
with only a subset of fields that can be accessed.

Future work is this area is ongoing. For example, a CanCan integration 
could be a much simpler way of separating out this logic.

## Documentation

### Querying

Instantiate an instance of GraphQL-Api and get the `schema` object which is
a `GraphQL::Schema` instance from [graphql-ruby](https://rmosolgo.github.io/graphql-ruby).

```ruby
graph = GraphQL::Api::Schema.new(commands: [], models: [], queries: [])
graph.schema.execute('query { ... }')
```

GraphQL-Api will load in all models, query objects and commands from the rails
app directory automatically. If you store these in a different location
you can pass them in directly to the new command.

### Model Objects

Model objects are the core return value from GraphQL-Api. They can be a plain
old ruby object or they can be an active record model. Active record models
have more automatic inference, whereas poro objects are more flexible.

#### Active Record

GraphQL-Api reads your associations and columns from your models and creates
a graphql schema from them. In the examples above you can see that 'Author'
is automatically accessible from the 'Blog' object because the belongs to
relationship is set up. Column types are also inferred.

GraphQL-Api will set up two queries on the main Graphql query object. One for
a single record and another for a collection. You can override these queries
by setting a `graph_find(args, ctx)` and `graph_where(args, ctx)` class 
methods on your model. The `ctx` parameter will contain the context passed
in from the controller while the `args` parameter will contain the arguments
passed into the graphql query.

#### Poro

Plain old ruby objects are supported by implementing a class method called
`fields` on the object that returns the expected [types](#types) hash. 
Methods on the Poro should be defined with the same name as the provided
fields.

### Command Objects

Command objects are an object oriented approach to defining mutations.
They take a set of inputs as well as a graphql context and provide a
`perform` method that returns a Graphql understandable type. These objects
give you an object oriented abstraction for handling mutations.

Command objects must implement the interface defined in `GraphQL::Api::CommandType`.

To better model controllers, you can define the commands `actions` this
will allow a command to respond to multiple methods on the same class. For
example, the following code will model a restful controller using commands.
The mutation will be prefixed with the action name. For example, the code
below will create a `updateBlogCommand` mutation as well as a `deleteBlogCommand`.

```ruby
class BlogCommand < GraphQL::Api::CommandType
  inputs name: :string, tags: [:string], id: :integer
  returns blog: Blog
  
  # this tells GraphQL-Api to make two mutations that call the below methods.
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
```

### Query Objects

Query objects are designed to provide a wrapper around complex queries
with potentially a lot of inputs. They return a single type or array of
types.

Query objects must implement the interface defined in `GraphQL::Api::QueryType`

### Customization

Sometimes you cannot fit every possible use case into a library like GraphQL-Api
as a result, you can always drop down to the excellent Graphql library for
ruby to combine both hand rolled and GraphQL-Api graphql schemas. Here is an
example creating a custom mutation.

```ruby
simple_mutation = GraphQL::Relay::Mutation.define do
  input_field :name, !types.String
  return_field :item, types.String
  resolve -> (inputs, ctx) {  {item: 'hello'}  }
end

graph = GraphQL::Api::Schema.new
mutation = graph.mutation do
  field 'simpleMutation', simple_mutation.field
end

schema = GraphQL::Schema.define(query: graph.query, mutation: mutation)
puts schema.execute('mutation { simpleMutation(input: {name: "hello"}) { item } }')
```

The `GraphQL::Api::Schema#mutation` and `GraphQL::Api::Schema#query` methods accept
a block that allows you to add custom fields or methods to the mutation or
query definitions. You can refer to the [graphql-ruby](https://rmosolgo.github.io/graphql-ruby)
docs for how to do this.

### Types

Field types and argument types are all supplied as a hash of key value 
pairs. An exclamation mark at the end of the type marks it as required, 
and wrapping the type in an array marks it as a list of that type.

```ruby
{
    name: :string,
    more_names: [:string],
    required: :integer!,
}
```

The supported types are:

- integer
- text
- string
- decimal
- float
- boolean

Note, these are the same as active record's column types for consistency.


## Roadmap

- [ ] Customizing resolvers
- [ ] CanCan support
- [ ] Relay support
- [ ] Additional object support (enums, interfaces ...)
- [ ] Support non rails frameworks
