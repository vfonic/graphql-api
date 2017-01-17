require "graphql/api/types"
require "graphql/api/helpers"
require "graphql/api/resolvers/model_find_query"
require "graphql/api/resolvers/model_list_query"
require "graphql/api/resolvers/query_object_query"

module GraphQL::Api
  # Allows the following DSL:
  #
  # GraphQL::Api.configure do
  #   model User, only: [:create, :update, :delete, :show, :index]
  #   command
  #   query
  # end

  class ApiQueryType
    attr_accessor :name, :type, :args, :resolver

    def initialize(name, type, args, resolver)
      @name = name
      @type = type
      @args = args
      @resolver = resolver
    end

    def mutation_type?
      false
    end

    def query_type?
      true
    end

    def to_s
      "#<Query #{name} type=#{type.name}>"
    end

  end

  class ApiMutationType
    attr_accessor :name, :type

    def initialize(type)
      @type = type
    end

    def mutation_type?
      true
    end

    def query_type?
      false
    end

    def name
      @type.name.camelize(:lower)
    end

    def to_s
      "#<Mutation #{name} type=#{type.name}>"
    end

  end

  class Configure
    include Types
    include Helpers

    def initialize
      @types = {} # maps simple types to graphql query types, not needed for mutations
      @graphql_objects = []
    end

    def schema
      @schema ||= GraphQL::Schema.define(query: graphql_query, mutation: graphql_mutation)
    end

    def model(model, only: nil)
      if model < ActiveRecord::Base
        if only
          only.each do |method|
            send("model_#{method}", model)
          end
        else
          model_show(model)
          model_index(model)
          model_create(model)
          model_delete(model)
          model_update(model)
        end
      else
        with_model(model)
      end
    end

    def command(model, action = :perform)
      mutation = command_mutation_type(model, action)
      @graphql_objects << ApiMutationType.new(mutation)
    end

    def query(model)
      args = model.try(:arguments)
      name = model.name.camelize(:lower)
      type = graphql_type_for_object(model.return_type, @types)

      @graphql_objects << ApiQueryType.new(name, type, args, Resolvers::QueryObjectQuery.new(model))
    end

    def with_model(model)
      query = @types[model]
      unless query
        query = model_query_type(model)
        @types[model] = query
      end
      query
    end

    def model_show(model, args = {})
      type = with_model(model)

      args[:id] = :id
      name = model.name.camelize(:lower)

      @graphql_objects << ApiQueryType.new(name, type, args, Resolvers::ModelFindQuery.new(model))
    end

    def model_index(model, args = {})
      type = with_model(model).to_list_type

      name = model.name.camelize(:lower).pluralize
      args[:limit] = :integer

      @graphql_objects << ApiQueryType.new(name, type, args, Resolvers::ModelListQuery.new(model))
    end

    def model_create(model)
      mutation = model_mutation_create_type(model)
      @graphql_objects << ApiMutationType.new(mutation)
    end

    def model_update(model)
      mutation = model_mutation_update_type(model)
      @graphql_objects << ApiMutationType.new(mutation)
    end

    def model_delete(model)
      mutation = model_mutation_delete_type(model)
      @graphql_objects << ApiMutationType.new(mutation)
    end

    def graphql_query(&block)
      graphql_objects = @graphql_objects
      GraphQL::ObjectType.define do
        name 'Query'
        description 'The query root for this schema'

        instance_eval(&block) if block

        graphql_objects.each do |object|
          unless object.query_type?
            next
          end

          field(object.name) do
            type object.type
            object.args.each do |arg, arg_type|
              argument arg, graphql_type_of(arg_type)
            end
            resolve object.resolver
          end
        end
      end
    end

    def graphql_mutation(&block)
      graphql_objects = @graphql_objects
      GraphQL::ObjectType.define do
        name 'Mutation'
        description 'The mutation root for this schema'

        instance_eval(&block) if block

        graphql_objects.each do |object|
          unless object.mutation_type?
            next
          end

          field(object.name, field: object.type.field)
        end
      end
    end

  end
end
