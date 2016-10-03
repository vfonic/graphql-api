require 'graphql/api/command_type'
require 'graphql/api/query_type'
require 'graphql/api/helpers'
require 'graphql/api/schema_error'
require 'graphql/api/resolvers/model_create_mutation'
require 'graphql/api/resolvers/model_delete_mutation'
require 'graphql/api/resolvers/model_update_mutation'
require 'graphql/api/resolvers/model_find_query'
require 'graphql/api/resolvers/model_list_query'
require 'graphql/api/resolvers/query_object_query'
require 'graphql/api/resolvers/command_mutation'
require 'graphql/api/resolvers/field'
require 'graphql'

include GraphQL::Api::Helpers

module GraphQL::Api
  class Schema

    def initialize(commands: [], queries: [], models: [])
      @types = {}
      @mutations = {}

      @load_commands = commands
      @load_queries = queries
      @load_models = models

      build_model_types
      build_mutations
      build_object_types
    end

    def all_models
      @all_models ||= all_constants('models') + @load_models
    end

    def all_queries
      @all_queries ||= all_constants('queries') + @load_queries
    end

    def all_commands
      @all_commands ||= all_constants('commands') + @load_commands
    end

    def create_type(model_class)
      object_types = @types

      GraphQL::ObjectType.define do
        name model_class.name
        description "Get #{model_class.name}"

        if model_class.respond_to?(:columns)
          model_class.columns.each do |column|
            field column.name do
              type graphql_type(column)
              resolve Resolvers::Field.new(model_class, column.name)
            end
          end
        end

        if model_class.respond_to?(:fields)
          model_class.fields.each do |field_name, field_type|
            field field_name, graphql_type_of(field_type)
          end
        end

        if model_class.respond_to?(:reflections)
          model_class.reflections.each do |name, association|
            field name do
              if association.collection?
                type types[object_types[association.class_name.constantize]]
              else
                type object_types[association.class_name.constantize]
              end
              resolve Resolvers::Field.new(model_class, name)
            end
          end
        end

      end
    end

    def create_command_type(object_type, action)
      object_types = @types

      GraphQL::Relay::Mutation.define do
        name object_type.name
        description "Command #{object_type.name} #{action}"

        object_type.inputs.each do |input, type|
          input_field input, graphql_type_of(type)
        end

        object_type.returns.each do |return_name, return_type|
          return_field return_name, graphql_type_for_object(return_type, object_types)
        end

        resolve Resolvers::CommandMutation.new(object_type, action)
      end
    end

    def create_mutation(model_class)
      return nil unless model_class < ActiveRecord::Base

      object_types = @types

      GraphQL::Relay::Mutation.define do
        name "Create#{model_class.name}"
        description "Create #{model_class.name}"

        model_class.columns.each do |column|
          input_field column.name, graphql_type(column)
        end

        return_field model_class.name.underscore.to_sym, object_types[model_class]
        resolve Resolvers::ModelCreateMutation.new(model_class)
      end
    end

    def update_mutation(model_class)
      return nil unless model_class < ActiveRecord::Base

      object_types = @types

      GraphQL::Relay::Mutation.define do
        name "Update#{model_class.name}"
        description "Update #{model_class.name}"

        input_field :id, !types.ID
        model_class.columns.each do |column|
          input_field column.name, graphql_type(column)
        end

        return_field model_class.name.underscore.to_sym, object_types[model_class]
        resolve Resolvers::ModelUpdateMutation.new(model_class)
      end
    end

    def delete_mutation(model_class)
      return nil unless model_class < ActiveRecord::Base

      GraphQL::Relay::Mutation.define do
        name "Delete#{model_class.name}"
        description "Delete #{model_class.name}"

        input_field :id, !types.ID

        return_field "#{model_class.name.underscore}_id".to_sym, types.ID
        resolve Resolvers::ModelDeleteMutation.new(model_class)
      end
    end

    def query(&block)
      object_types = @types

      GraphQL::ObjectType.define do
        name 'Query'
        description 'The query root for this schema'

        instance_eval(&block) if block

        object_types.each do |object_class, graph_type|
          if object_class < ActiveRecord::Base

            field(object_class.name.camelize(:lower)) do
              type graph_type
              argument :id, types.ID

              if object_class.respond_to?(:arguments)
                object_class.arguments.each do |arg|
                  argument arg, graphql_type(object_class.columns.find { |c| c.name.to_sym == arg.to_sym })
                end
              end

              resolve Resolvers::ModelFindQuery.new(object_class)
            end

            field(object_class.name.camelize(:lower).pluralize) do
              type types[graph_type]
              argument :limit, types.Int

              if object_class.respond_to?(:arguments)
                object_class.arguments.each do |arg|
                  argument arg, graphql_type(object_class.columns.find { |c| c.name.to_sym == arg.to_sym })
                end
              end

              resolve Resolvers::ModelListQuery.new(object_class)
            end

          elsif object_class.respond_to?(:arguments) && object_class.respond_to?(:return_type)

            field(object_class.name.camelize(:lower)) do
              type(graphql_type_for_object(object_class.return_type, object_types))

              object_class.arguments.each do |argument_name, argument_type|
                argument argument_name, graphql_type_of(argument_type)
              end

              resolve Resolvers::QueryObjectQuery.new(object_class)
            end

          end
        end

      end
    end

    def mutation(&block)
      mutations = @mutations

      GraphQL::ObjectType.define do
        name 'Mutation'
        instance_eval(&block) if block

        mutations.each do |model_class, muts|
          muts.each do |mutation|
            field mutation[0], field: mutation[1].field
          end
        end
      end
    end

    def schema
      @schema ||= GraphQL::Schema.define(query: query, mutation: mutation)
    end

    def build_model_types
      all_models.each { |model_class| @types[model_class] = create_type(model_class) }
    end

    def build_object_types
      all_queries.each { |query| @types[query] = nil }
    end

    def build_mutations
      all_models.each do |model_class|
        @mutations[model_class] = [
            ["create#{model_class.name}", create_mutation(model_class)],
            ["update#{model_class.name}", update_mutation(model_class)],
            ["delete#{model_class.name}", delete_mutation(model_class)],
        ].map { |x| x if x[1] }.compact
      end

      all_commands.each do |command|
        if command.respond_to?(:actions) && command.actions.any?
          @mutations[command] = []
          command.actions.each do |action|
            @mutations[command] << ["#{action}#{command.name}", create_command_type(command, action)]
          end
        else
          @mutations[command] = [
              [command.name.camelize(:lower), create_command_type(command, :perform)]
          ]
        end
      end
    end

  end
end
