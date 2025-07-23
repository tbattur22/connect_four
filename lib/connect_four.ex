defmodule ConnectFour do
  # alias ConnectFour.Impl.Game
  require Logger
  alias ConnectFour.Runtime.Server

  @opaque game :: Server.t
  @registry :connectfour_server_registry

  def new_game(game_id, uid1, uid2) do
    case Registry.lookup(@registry, "ConnectFourServer_" <> game_id) do
      [] ->
        {:ok, pid} = ConnectFour.Runtime.Application.start_game(game_id, uid1, uid2)
        pid

      [{pid2, _}] ->
        pid2
    end
  end

  # def join_game(game, uid) do
  #   GenServer.call(game, { :join_game, uid})
  # end

  def game_state(game_id) do
    case Registry.lookup(@registry, "ConnectFourServer_" <> game_id) do
      [] ->
        registeredServerName = "ConnectFourServer_" <> game_id
        Logger.warning("No process registered with name #{registeredServerName}")
        {:error, "No process registered with name #{registeredServerName} "}
      [{pid2, _}] ->
        {:ok, GenServer.call(pid2, { :game_state })}
    end
  end

  def make_move(game, uid, col_index) do
    GenServer.call(game, { :make_move, uid, col_index})
  end

  def play_again(game) do
    GenServer.call(game, {:play_again})
  end

  def game_id(game) do
    GenServer.call(game, {:game_id})
  end

  def game_pid(game_id) when is_binary(game_id) do
    case Registry.lookup(@registry, "ConnectFourServer_" <> game_id) do
      [] ->
        Logger.warning("No server process found for game id #{game_id}")
        {:error, "No server process found for game id #{game_id}"}
      [{pid, _}] ->
        Logger.info("Returning game pid #{inspect(pid)} by game id #{game_id}")
        {:ok, pid}
    end
  end
  def game_pid(game_id), do: {:error, "game_id must be of type String(binary) but got #{inspect(game_id)}"}
end
