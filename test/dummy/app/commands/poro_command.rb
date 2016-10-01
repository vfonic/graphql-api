class PoroCommand < Graphite::CommandType
  inputs name: :string
  returns :poro, Poro

  def perform
    Poro.new(inputs[:name])
  end

end
