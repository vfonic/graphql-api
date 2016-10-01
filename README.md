# Graphite
Graphite is a graphql framework for Rails that supports auto generating 
queries based on Active Record models and plain Ruby objects. Don't 
manually define Graphql structures, let Graphite handle it for you.

## Example

Given the following model structure:

```ruby
class Author < ActiveRecord::Base
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

mutation createBlog { createBlog(input: {title: "test", author_id: 2}) { blog { id } } }

mutation { updateBlog(input: {id: 1, title: "test"}) { blog { id } } }

mutation { deleteBlog(input: {id: 1}) { blog_id } }
```

Graphite also has support for command objects:
```ruby
# Graphql mutation derived from the below command object:
# mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }

class BlogCreateCommand < Graphite::CommandType
  inputs name: :string, tags: [:string]
  returns :blog, Blog

  def perform
    # do something and return the ActiveRecord Blog model
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

## Documentation

### Model Objects

#### Active Record

#### Poro

#### Authorization

### Command Objects

### Query Objects
