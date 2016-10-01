class BlogCreateCommand < Graphite::CommandType
  inputs name: :string
  returns :poro, Poro

  def perform
    Poro.new(input[:name])
  end

  class Poro
    attr_accessor :name
    def initialize(name)
      @name = name
    end
  end

end
