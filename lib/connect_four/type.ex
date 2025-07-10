defmodule ConnectFour.Type do

  @type state :: nil | :playing | { :win, :red} | :draw
  @type player :: nil | :red | :yellow

  # @type tally :: %{
  #   game_id: String.t,
  #   game_state: state,
  #   current_player: player,
  #   players: %{},
  #   board: list(list())
  # }
end
