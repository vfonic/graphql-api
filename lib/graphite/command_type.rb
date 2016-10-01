module Graphite
  class CommandType
    attr_accessor :ctx, :inputs

    def initialize(inputs, ctx)
      @inputs = inputs
      @ctx = ctx
    end

    def self.inputs(inputs=nil)
      @inputs = inputs if inputs
      @inputs || []
    end

    def self.returns(key, value)
      return_field(key)
      return_type(value)
    end

    def self.return_field(key=nil)
      @return_key = key if key
      @return_key
    end

    def self.return_type(type=nil)
      @return_type = type if type
      @return_type
    end

    def perform
    end

  end
end
