# frozen_string_literal: true

module GraphQL::Api
  class MutationDescription
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

    def name # rubocop:disable Lint/DuplicateMethods
      @type.name.camelize(:lower)
    end

    def to_s
      "#<Mutation #{name} type=#{type.name}>"
    end
  end
end
