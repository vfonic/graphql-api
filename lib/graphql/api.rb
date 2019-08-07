# frozen_string_literal: true

require 'graphql/api/resolvers/helpers'
require 'graphql/api/resolvers/model_find_query'
require 'graphql/api/resolvers/model_list_query'
require 'graphql/api/resolvers/query_object_query'
require 'graphql/api/resolvers/field'
require 'graphql/api/resolvers/model_create_mutation'
require 'graphql/api/resolvers/model_delete_mutation'
require 'graphql/api/resolvers/model_update_mutation'
require 'graphql/api/resolvers/command_mutation'
require 'graphql/api/helpers'
require 'graphql/api/types'
require 'graphql/api/mutation_description'
require 'graphql/api/query_description'
require 'graphql'
require 'graphql/api/unauthorized_exception'
require 'graphql/api/version'
require 'graphql/api/policy'
require 'graphql/api/command_policy'
require 'graphql/api/query_policy'
require 'graphql/api/command_type'
require 'graphql/api/query_type'
require 'graphql/api/configure'

module GraphQL
  module Api
    def self.schema(opts = {})
      @schema ||= configure_default_schema(opts)
    end

    def self.configure(&block)
      config = GraphQL::Api::Configure.new
      config.instance_eval(&block)
      @schema = config.schema
      @schema
    end

    def self.configure_default_schema(opts)
      config = GraphQL::Api::Configure.new
      config.with_defaults(opts)
      config.schema
    end
  end
end
