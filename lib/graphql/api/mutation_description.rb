# frozen_string_literal: true

module GraphQL::Api
  class MutationDescription
    attr_reader :type

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
end
