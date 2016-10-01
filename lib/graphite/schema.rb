require 'graphql'
require 'graphite/command_type'
require 'graphite/query_type'
require 'graphite/helpers'
require 'graphite/schema_error'

include Graphite::Helpers

module Graphite
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
      mutation
      query
      self
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
              resolve -> (obj, args, ctx) { graphql_fetch(obj, ctx, column.name) }
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
              resolve -> (obj, args, ctx) { graphql_fetch(obj, ctx, name) }
            end
          end
        end

      end
    end

    def create_query_type(query_class)
      GraphQL::ObjectType.define do
        name query_class.name

        query_class.fields.each do |field_name, field_type|
          field field_name, graphql_type_of(field_type)
        end
      end
    end

    def create_command_type(object_type)
      object_types = @types

      GraphQL::Relay::Mutation.define do
        name object_type.name
        description "Command #{object_type.name}"

        object_type.inputs.each do |input, type|
          input_field input, graphql_type_of(type)
        end

        if object_type.return_type.nil?
          raise SchemaError.new("return type is nil for command: #{object_type.name}")
        end

        if object_type.return_field.nil?
          raise SchemaError.new("return field is nil for command: #{object_type.name}")
        end

        if object_type.return_type.respond_to?(:to_sym) || object_type.return_type.is_a?(Array)
          return_field object_type.return_field, graphql_type_of(object_type.return_type.to_sym)
        else
          return_field object_type.return_field, object_types[object_type.return_type]
        end

        resolve -> (inputs, ctx) {
          {object_type.return_field => object_type.new(inputs, ctx).perform}
        }
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

        resolve -> (inputs, ctx) {
          item = model_class.create!(inputs.to_h)
          {model_class.name.underscore.to_sym => item}
        }
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

        resolve -> (inputs, ctx) {
          item = model_class.find(inputs[:id])
          item.update!(inputs.to_h)
          {model_class.name.underscore.to_sym => item}
        }
      end
    end

    def delete_mutation(model_class)
      return nil unless model_class < ActiveRecord::Base

      GraphQL::Relay::Mutation.define do
        name "Delete#{model_class.name}"
        description "Delete #{model_class.name}"

        input_field :id, !types.ID

        return_field "#{model_class.name.underscore}_id".to_sym, types.ID

        resolve -> (inputs, ctx) {
          item = model_class.find(inputs[:id]).destroy!
          {"#{model_class.name.underscore}_id".to_sym => item.id}
        }
      end
    end

    def query
      object_types = @types

      @query ||= GraphQL::ObjectType.define do
        name 'Query'
        description 'The query root for this schema'

        object_types.each do |object_class, graph_type|
          if object_class < QueryType

            field(object_class.name.underscore.to_sym) do
              type(graph_type)
              object_class.arguments.each do |argument_name, argument_type|
                argument argument_name, graphql_type_of(argument_type)
              end

              resolve -> (obj, args, ctx) {
                q = object_class.new(args, ctx)
                q.query
                q
              }
            end

          elsif object_class < ActiveRecord::Base

            field(object_class.name.camelize(:lower)) do
              type graph_type
              argument :id, types.ID

              if object_class.respond_to?(:arguments)
                object_class.arguments.each do |arg|
                  argument arg, graphql_type(object_class.columns.find { |c| c.name.to_sym == arg.to_sym })
                end
              end

              resolve -> (obj, args, ctx) {
                if object_class.respond_to?(:find_with_ctx)
                  object_class.find_with_ctx(args, ctx)
                else
                  object_class.find_by!(args.to_h)
                end
              }
            end

            field(object_class.name.camelize(:lower).pluralize) do
              type types[graph_type]
              argument :limit, types.Int

              if object_class.respond_to?(:arguments)
                object_class.arguments.each do |arg|
                  argument arg, graphql_type(object_class.columns.find { |c| c.name.to_sym == arg.to_sym })
                end
              end

              resolve -> (obj, args, ctx) {
                if object_class.respond_to?(:where_with_ctx)
                  object_class.where_with_ctx(args, ctx)
                else
                  eager_load = []
                  ctx.irep_node.children.each do |child|
                    eager_load << child[0] if object_class.reflections.find { |name, _| name == child[0] }
                  end

                  query_args = args.to_h
                  query_args.delete('limit')

                  q = object_class.where(query_args)
                  q.eager_load(*eager_load) if eager_load.any?
                  q.limit(args[:limit] || 30)
                end
              }
            end
          end
        end

      end
    end

    def mutation
      mutations = @mutations
      object_types = @types

      @mutation ||= GraphQL::ObjectType.define do
        mutations.each do |model_class, muts|
          muts.each do |mutation|
            field mutation[0], field: mutation[1].field
          end
        end

        object_types.each do |object_class, object_type|
          if object_class < CommandType
            field object_class.name.camelize(:lower), field: object_type.field
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
      all_commands.each { |command| @types[command] = create_command_type(command) }
      all_queries.each { |query| @types[query] = create_query_type(query) }
    end

    def build_mutations
      all_models.each do |model_class|
        @mutations[model_class] = [
            ["create#{model_class.name}", create_mutation(model_class)],
            ["update#{model_class.name}", update_mutation(model_class)],
            ["delete#{model_class.name}", delete_mutation(model_class)],
        ].map { |x| x if x[1] }.compact
      end
    end

  end
end
