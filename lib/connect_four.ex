defmodule ConnectFour do
  # alias ConnectFour.Impl.Game
  alias ConnectFour.Runtime.Server

  @opaque game :: Server.t
  @registry :connectfour_server_registry

  def new_game(uid) do
    case Registry.lookup(@registry, "ConnectFourServer_" <> Integer.to_string(uid)) do
      [] ->
        {:ok, pid} = ConnectFour.Runtime.Application.start_game(uid)
        pid

      [{pid2, _}] ->
        pid2
    end
  end
  def make_move(game, uid, col_index) do
    GenServer.call(game, { :make_move, uid, col_index})
  end

  def play_again(game) do
    GenServer.call(game, {:play_again})
  end
end
