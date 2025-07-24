defmodule ConnectFour.Runtime.Server do
  alias ConnectFour.Impl.Game
  alias ConnectFour.Runtime.Watchdog

  @type t :: pid()
  use GenServer

  @registry :connectfour_server_registry
  @idle_timeout 1 * 60 * 60 * 1000   # 1 hour

  # client process

  def start_link({game_id, uid1, uid2}) do
    name = "ConnectFourServer_" <> game_id
    GenServer.start_link(__MODULE__, {game_id, uid1, uid2}, name: {:via, Registry, {@registry, name}})
  end

  def child_spec({game_id, uid1, uid2}) do
    %{
      id: {:connect_four_server, game_id},
      start: {__MODULE__, :start_link, [{game_id, uid1, uid2}]},
      restart: :transient,  # only restart on abnormal exit
      shutdown: 5000,
      type: :worker
    }
  end

  # server process

  @impl true
  def init({game_id, uid1, uid2}) do
    Process.flag(:trap_exit, true)
    watcher = Watchdog.start(@idle_timeout)

    game = Game.new_game(game_id, uid1)

    {:ok,  {Game.new_game(game, uid2), watcher}}
  end

  @impl true
  def handle_call({ :game_state }, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {:reply, game, {game, watcher}}
  end

  @impl true
  def handle_call({ :make_move, uid, col_index}, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    updated_game = Game.make_move(game, uid, col_index)

    Phoenix.PubSub.broadcast(
      ConnectFour.PubSub,
      "game:#{updated_game.game_id}",
      {:make_move, updated_game}
    )

    {:reply, updated_game, {updated_game, watcher}}
  end

  @impl true
  def handle_call({ :board }, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {:reply, game.board, {game, watcher}}
  end

  @impl true
  def handle_call({ :play_again }, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    new_game = Game.play_again(game)

    {:reply, new_game, {new_game, watcher}}
  end

  @impl true
  def handle_call({ :game_id }, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {:reply,  game.game_id, {game, watcher}}
  end

  @impl true
  def handle_info({:watchdog_expired, _watchdog_pid}, _state) do
    IO.puts("ConnectFour game session expired due to inactivity.")
    {:stop, :normal, :expired}
  end
end
