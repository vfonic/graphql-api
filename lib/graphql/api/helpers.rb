# frozen_string_literal: true

module GraphQL::Api
  module Helpers
    def all_constants(root)
      Dir[Rails.root.join("app/#{root}/*")].map do |f|
        file = f.split('/')[-1]
        next unless file.end_with?('.rb')

        const = file.split('.')[0].camelize.constantize
        const unless const.respond_to?(:abstract_class) && const.abstract_class
      end.compact
    rescue StandardError
      []
    end

    def graphql_type_for_object(return_type, object_types) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      raise('Return type is nil for object') if return_type.nil?

      type = if return_type.respond_to?(:to_sym) || (return_type.is_a?(Array) && return_type[0].respond_to?(:to_sym))
               graphql_type_of(return_type.to_sym)
             elsif return_type.is_a?(Array)
               object_types[return_type[0]].to_list_type
             else
               object_types[return_type]
             end

      raise("Could not parse return type for: #{return_type}") if type.nil?

      type
    end

    def graphql_type_of(type) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      is_required = false
      if type.to_s.end_with?('!')
        is_required = true
        type = type.to_s.chomp('!').to_sym
      end

      is_list = false
      if type.is_a?(Array)
        is_list = true
        type = type[0]
      end

      res = case type
            when :id
              GraphQL::ID_TYPE
            when :integer
              GraphQL::INT_TYPE
            when :text
              GraphQL::STRING_TYPE
            when :string
              GraphQL::STRING_TYPE
            when :decimal
              GraphQL::FLOAT_TYPE
            when :float
              GraphQL::FLOAT_TYPE
            when :boolean
              GraphQL::BOOLEAN_TYPE
            else
              GraphQL::STRING_TYPE
            end

      res = res.to_list_type if is_list
      res = !res if is_required

      res
    end

    def graphql_type(column)
      graphql_type_of(column.type)
    end
  end
end
