class Poro
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def self.fields
    {
        name: :string
    }
  end

end
