# frozen_string_literal: true

class BlockedQuery < GraphQL::Api::QueryType
  action :execute, returns: [Blog], args: { name: :string }

  def execute
    Blog.all
  end
end
