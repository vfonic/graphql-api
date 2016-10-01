module GraphQL::Api
  class CommandType
    attr_accessor :ctx, :inputs

    def initialize(inputs, ctx)
      @inputs = inputs
      @ctx = ctx
    end

    def self.inputs(inputs=nil)
      @inputs = inputs if inputs
      @inputs || {}
    end

    def self.returns(fields=nil)
      @returns = fields if fields
      @returns || {}
    end

    def perform
    end

  end
end
