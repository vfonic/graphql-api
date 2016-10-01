module Graphite
  module Helpers
    def all_constants(root)
      begin
        Dir["#{Rails.root}/app/#{root}/*"].map do |f|
          file = f.split('/')[-1]
          if file.end_with?('.rb')
            const = file.split('.')[0].camelize.constantize
            const unless const.try(:abstract_class)
          end
        end.compact
      rescue
        []
      end
    end

    def graphql_type_for_object(object_class, object_types)
      if object_class.return_type.nil?
        raise SchemaError.new("return type is nil for object: #{object_class.name}")
      end

      if object_class.return_type.respond_to?(:to_sym) || (object_class.return_type.is_a?(Array) && object_class.return_type[0].respond_to?(:to_sym))
        type = graphql_type_of(object_class.return_type.to_sym)
      elsif object_class.return_type.is_a?(Array)
        type = object_types[object_class.return_type[0]].to_list_type
      else
        type = object_types[object_class.return_type]
      end

      if type.nil?
        raise SchemaError.new("could not parse return type for: #{object_class.name}, #{object_class.return_type}")
      end

      type
    end

    def graphql_type_of(type)
      is_list = false
      if type.is_a?(Array)
        is_list = true
        type = type[0]
      end

      case type
        when :integer
          res = GraphQL::INT_TYPE
        when :text
          res = GraphQL::STRING_TYPE
        when :string
          res = GraphQL::STRING_TYPE
        when :decimal
          res = GraphQL::FLOAT_TYPE
        when :float
          res = GraphQL::FLOAT_TYPE
        when :boolean
          res = GraphQL::BOOLEAN_TYPE
        else
          res = GraphQL::STRING_TYPE
      end

      if is_list
        res.to_list_type
      else
        res
      end
    end

    def graphql_type(column)
      graphql_type_of(column.type)
    end

    def graphql_fetch(obj, ctx, name)
      if obj.respond_to?("access_#{name}?")
        obj.send(name) if obj.send("access_#{name}?", ctx)
      else
        obj.send(name)
      end
    end
  end
end
