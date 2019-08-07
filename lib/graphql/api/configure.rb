# frozen_string_literal: true

include GraphQL::Api::Helpers # rubocop:disable Style/MixinUsage

module GraphQL::Api
  class Configure # rubocop:disable Metrics/ClassLength
    include Types
    attr_accessor :command_resolver, :query_resolver, :field_resolver, :model_create_resolver, :model_delete_resolver,
                  :model_update_resolver, :model_find_resolver, :model_list_resolver

    def initialize
      @types = {} # maps simple types to graphql query types, not needed for mutations
      @graphql_objects = []

      @command_resolver = Resolvers::CommandMutation
      @query_resolver = Resolvers::QueryObjectQuery
      @field_resolver = Resolvers::Field
      @model_create_resolver = Resolvers::ModelCreateMutation
      @model_update_resolver = Resolvers::ModelUpdateMutation
      @model_delete_resolver = Resolvers::ModelDeleteMutation
      @model_find_resolver = Resolvers::ModelFindQuery
      @model_list_resolver = Resolvers::ModelListQuery
    end

    # Return the graphQL schema
    def schema
      @schema ||= GraphQL::Schema.define(
        query: graphql_query,
        mutation: graphql_mutation,
        resolve_type: lambda { |obj, ctx| @types[obj.class] }
      )
    end

    def with_defaults(commands: [], queries: [], models: []) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      (all_constants('models') + models).each do |model_class|
        model(model_class)
      end
      (all_constants('queries') + queries).each do |query_class|
        query_class.actions.keys.each do |action|
          query(query_class, action: action)
        end
      end
      (all_constants('commands') + commands).each do |command_class|
        command_class.actions.keys.each do |action|
          command(command_class, action: action)
        end
      end
    end

    def model(model, only: nil, args: {}) # rubocop:disable Metrics/MethodLength
      if model < ActiveRecord::Base
        if only
          only.each do |method|
            send("model_#{method}", model)
          end
        else
          model_show(model, args: args)
          model_index(model, args: args)
          model_create(model)
          model_delete(model)
          model_update(model)
        end
      else
        with_model(model)
      end
    end

    def mutation_description(mutation_description)
      raise('Mutation must be called with a MutationDescription') unless mutation_description.mutation_type?

      @graphql_objects << mutation_description
    end

    def query_description(query_description)
      raise('Mutation must be called with a MutationDescription') unless query_description.query_type?

      @graphql_objects << query_description
    end

    def command(model, action: :perform, resolver: nil)
      raise("Action #{action} does not exist on #{model.name}") unless model.actions[action]

      mutation = command_mutation_type(model, action, resolver: resolver, resolver_class: command_resolver)
      @graphql_objects << MutationDescription.new(mutation)
    end

    def query(model, action: :execute, resolver: nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      raise("Action does not exist on #{model.name}") unless model.actions[action]

      returns = model.actions[action][:returns]
      args = model.actions[action][:args]

      name = if action == :execute
               model.name.camelize(:lower)
             else
               "#{action}#{model.name.camelize}"
             end

      type = graphql_type_for_object(returns, @types)
      resolver ||= query_resolver.new(model, action)
      @graphql_objects << QueryDescription.new(name, type, args, resolver)
    end

    def with_model(model, fields: {})
      query = @types[model]
      unless query
        query = model_query_type(model, fields: fields, resolver_class: field_resolver)
        @types[model] = query
      end
      query
    end

    def model_show(model, args: {}, fields: {}, resolver: nil)
      type = with_model(model, fields: fields)
      name = model.name.camelize(:lower)
      args[:id] = :id

      resolver ||= model_find_resolver.new(model)
      @graphql_objects << QueryDescription.new(name, type, args, resolver)
    end

    def model_index(model, args: {}, resolver: nil)
      type = with_model(model).to_list_type
      name = model.name.camelize(:lower).pluralize

      resolver ||= model_list_resolver.new(model)
      @graphql_objects << QueryDescription.new(name, type, args, resolver)
    end

    def model_create(model, resolver: nil)
      mutation = model_mutation_create_type(model, resolver: resolver, resolver_class: model_create_resolver)
      @graphql_objects << MutationDescription.new(mutation)
    end

    def model_update(model, resolver: nil)
      mutation = model_mutation_update_type(model, resolver: resolver, resolver_class: model_update_resolver)
      @graphql_objects << MutationDescription.new(mutation)
    end

    def model_delete(model, resolver: nil)
      mutation = model_mutation_delete_type(model, resolver: resolver, resolver_class: model_delete_resolver)
      @graphql_objects << MutationDescription.new(mutation)
    end

    def graphql_query(&block) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      graphql_objects = @graphql_objects
      GraphQL::ObjectType.define do
        name 'Query'
        description 'The query root for this schema'

        instance_eval(&block) if block

        graphql_objects.each do |object|
          next unless object.query_type?

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
          next unless object.mutation_type?

          field(object.name, field: object.type.field)
        end
      end
    end
  end
end
