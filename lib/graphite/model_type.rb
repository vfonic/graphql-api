module Graphite
  class ModelType

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
