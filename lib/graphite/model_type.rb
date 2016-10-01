module Graphite
  class ModelType

    def self.fields(fields=nil)
      @fields = fields if fields
      @fields || []
    end

    def query
    end

  end
end
