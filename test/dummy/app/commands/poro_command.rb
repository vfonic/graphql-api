class PoroCommand < Graphite::CommandType
  inputs name: :string
  returns poro: Poro

  def perform
    puts "current user: #{ctx[:current_user]}"
    {poro: Poro.new(inputs[:name])}
  end

end
