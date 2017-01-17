require "graphql/api/version"
require "graphql/api/policy"
require "graphql/api/schema"
require "graphql/api/configure"

module GraphQL
  module Api

    def self.schema(opts={})
      GraphQL::Api::Schema.new(opts).schema
    end

    def self.graph(opts={})
      GraphQL::Api::Schema.new(opts)
    end

    def self.configure(&block)
      config = GraphQL::Api::Configure.new
      config.instance_eval(&block)
      config.schema
    end

  end
end
