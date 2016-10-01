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
