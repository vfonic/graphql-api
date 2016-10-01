require "graphql/api/version"
require "graphql/api/schema"

module GraphQL
  module Api

    def self.schema(opts={})
      GraphQL::Api::Schema.new(opts).schema
    end

    def self.graph(opts={})
      GraphQL::Api::Schema.new(opts)
    end

  end
end
