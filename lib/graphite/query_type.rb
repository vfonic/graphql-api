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

    def self.return_type(type=nil)
      @return_type = type if type
      @return_type
    end

    def execute
    end

  end
end
