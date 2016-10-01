# Graphite
Graphite is a graphql framework for Rails that supports auto generating 
queries based on Active Record models and plain Ruby objects. Don't 
manually define Graphql structures, let Graphite handle it for you.

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

Graphite will respond to the following queries for the blog resource:

```graphql
query { blog(id: 1) { id, title, author { name } } }

query { blogs(limit: 5) { id, title, author { name } } }

mutation { createBlog(input: {name: "test", author_id: 2}) { blog { id } } }

mutation { updateBlog(input: {id: 1, title: "test"}) { blog { id } } }

mutation { deleteBlog(input: {id: 1}) { blog_id } }
```

Graphite also has support for command objects:
```ruby
# Graphql mutation derived from the below command object:
# mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }

class BlogCreateCommand < Graphite::CommandType
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

class BlogQuery < Graphite::QueryType
  arguments name: :string, content_matches: [:string]
  return_type [Blog]

  def execute
    Blog.all
  end

end
```

## Contents

1. [Guides](#guides)
    2. [Authorization](#authorization)
2. [Documentation](#Documentation)
    1. [Model Objects](#model-objects)

## Guides

### Authorization

Graphite will check for an `access_<field>?(ctx)` method on all model 
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

Future work is this area is ongoing. For example, policy objects could be
used to restrict access and apply scopes for certain users that remove
all authorization logic from the model.

## Documentation

### Querying

Instantiate an instance of Graphite and get the `schema` object which is
a `GraphQL::Schema` instance from [graphql-ruby](https://rmosolgo.github.io/graphql-ruby).

```ruby
graphite = Graphite::Schema.new(commands: [], models: [], queries: [])
graphite.execute('query { ... }')
```

Graphite will load in all models, query objects and commands from the rails
app directory automatically. If you store these in a different location
you can pass them in directly to the new command.

### Model Objects

Model objects are the core return value from Graphite. They can be a plain
old ruby object or they can be an active record model. Active record models
have more automatic inference, whereas poro objects are more flexible.

#### Active Record

Graphite reads your associations and columns from your models and creates
a graphql schema from them. In the examples above you can see that 'Author'
is automatically accessible from the 'Blog' object because the belongs to
relationship is set up. Column types are also inferred.

Graphite will set up two queries on the main Graphql query object. One for
a single record and another for a collection. You can override these queries
by setting a `graph_find(args, ctx)` and `graph_where(args, ctx)` class 
methods on your model. The `ctx` parameter will contain the context passed
in from the controller while the `args` parameter will contain the arguments
passed into the graphql query.

#### Poro

Plain old ruby objects are supported by providing a class method called
`fields` on the object that should return a hash of key value pairs with
the key being the field name and the value representing the key type:

    { name: :string }

Methods on the Poro should be defined with the same name as the provided
fields.

### Command Objects

Command objects are an object oriented approach to defining mutations.
They take a set of inputs as well as a graphql context and provide a
`perform` method that returns a Graphql understandable type. These objects
give you an object oriented abstraction for handling mutations.

Command objects must implement the interface defined in `Graphite::CommandType`

### Query Objects

Query objects are designed to provide a wrapper around complex queries
with potentially a lot of inputs. They return a single type or array of
types.

Query objects must implement the interface defined in `Graphite::QueryType`

### Customization

Sometimes you cannot fit every possible use case into a library like Graphite
as a result, you can always drop down to the excellent Graphql library for
ruby to combine both hand rolled and Graphite graphql schemas. Here is an
example creating a custom mutation.

```ruby
simple_mutation = GraphQL::Relay::Mutation.define do
  input_field :name, !types.String
  return_field :item, types.String
  resolve -> (inputs, ctx) {  {item: 'hello'}  }
end

graphite = Graphite::Schema.new
mutation = graphite.mutation do
  field 'simpleMutation', simple_mutation.field
end

schema = GraphQL::Schema.define(query: graphite.query, mutation: mutation)
puts schema.execute('mutation { simpleMutation(input: {name: "hello"}) { item } }')
```

The `Graphite::Schema#mutation` and `Graphite::Schema#query` methods accept
a block that allows you to add custom fields or methods to the mutation or
query definitions. You can refer to the [graphql-ruby](https://rmosolgo.github.io/graphql-ruby)
docs for how to do this.

## Roadmap

[ ] Relay support
[ ] Additional object support (enums, interfaces ...)
