class BlockedCommand < GraphQL::Api::CommandType
  inputs name: :string
  returns poro: Poro

  def perform
    {poro: Poro.new(inputs[:name])}
  end

end
