module Graphite
  class QueryType

    def initialize(inputs, ctx)
      @inputs = inputs
      @ctx = ctx
    end

    def self.arguments(arguments=nil)
      @arguments = arguments if arguments
      @arguments || []
    end

    def self.fields(fields=nil)
      @fields = fields if fields
      @fields || []
    end

    def query
    end

  end
end
