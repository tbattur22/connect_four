defmodule ConnectFour.Runtime.Server do
  alias ConnectFour.Impl.Game
  @type t :: pid()
  use GenServer

  @registry :connectfour_server_registry

  # client process

  def start_link({game_id, uid1, uid2}) do
    name = "ConnectFourServer_" <> game_id
    GenServer.start_link(__MODULE__, {game_id, uid1, uid2}, name: {:via, Registry, {@registry, name}})
  end

  # server process

  def init({game_id, uid1, uid2}) do
    game = Game.new_game(game_id, uid1)

    {:ok,  Game.new_game(game, uid2)}
  end

  def handle_call({ :game_state }, _from, game) do
    {:reply, game, game}
  end

  def handle_call({ :make_move, uid, col_index}, _from, game) do
    updated_game = Game.make_move(game, uid, col_index)

    Phoenix.PubSub.broadcast(
      ConnectFour.PubSub,
      "game:#{updated_game.game_id}",
      {:make_move, updated_game}
    )

    {:reply, updated_game, updated_game}
  end

  def handle_call({ :board }, _from, game) do
    {:reply, game.board, game}
  end

  def handle_call({ :play_again }, _from, game) do
    new_game = Game.play_again(game)

    {:reply, new_game, new_game}
  end

  def handle_call({ :game_id }, _from, game) do
    {:reply,  game.game_id, game}
  end
end
