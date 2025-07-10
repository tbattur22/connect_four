defmodule ConnectFour do
  alias ConnectFour.Impl.Game

  defdelegate new_game(uid), to: Game
  defdelegate new_game(game, uid), to: Game
  defdelegate make_move(game, uid, col_index), to: Game
end
