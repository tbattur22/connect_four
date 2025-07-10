defmodule ConnectFour.Runtime.Server do
  alias ConnectFour.Impl.Game
  @type t :: pid()
  use GenServer

  @registry :connectfour_server_registry

  # client process

  def start_link(uid) do
    name = "ConnectFourServer_" <> Integer.to_string(uid)
    GenServer.start_link(__MODULE__, uid, name: {:via, Registry, {@registry, name}})
  end

  # server process

  def init(uid) do
    {:ok, Game.new_game(uid) }
  end

  def handle_call({ :join_game, uid}, _from, game) do
    game = Game.new_game(game, uid)

    Phoenix.PubSub.broadcast(
      ConnectFour.PubSub,
      "game:#{game.game_id}",
      {:join_game, game}
    )

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
end
