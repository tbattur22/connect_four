defmodule ConnectFourTest do
  use ExUnit.Case
  alias ConnectFour.Impl.Game
  # doctest ConnectFour

  test "new game returns initial game state" do
    game_id = UUID.uuid1()
    game = Game.new_game(game_id, 22)

    assert String.length(game.game_id) > 0
    assert game.game_state == nil
    assert game.current_player == :red
    assert game.players == %{ red: 22, yellow: nil}
    assert game.board == [
      [nil,nil,nil,nil,nil,nil],#1st column (left most is bottom)
      [nil,nil,nil,nil,nil,nil],#2nd column
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
    ]
  end

  test "Test Runtime Exception invalid user id passed to new_game" do
    game_id = UUID.uuid1()
    assert_raise RuntimeError, "Invalid user id passed 22", fn ->
      Game.new_game(game_id, "22")
    end
  end

  test "two players are ready to start playing" do
    game_id = UUID.uuid1()
    game = Game.new_game(game_id, 22)
    game = Game.new_game(game, 33)

    assert String.length(game.game_id) > 0
    assert game.game_state == :playing
    assert game.current_player == :red
    assert game.players == %{ red: 22, yellow: 33}
    assert game.board == [
      [nil,nil,nil,nil,nil,nil],#1st column (left most is bottom)
      [nil,nil,nil,nil,nil,nil],#2nd column
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil],
    ]
  end

  test "state does not change if a game is won or drawed" do
    game_id = UUID.uuid1()
    for state <- [{ :win, :red}, { :win, :yellow}, :draw] do
      game =
        Game.new_game(game_id, 22)
        |> Game.new_game(23)
        |> Map.put(:game_state, state)

      gameReturned = Game.make_move(game, 22, 3)
      assert gameReturned == game
    end
  end

  test "player cannot make two moves in a row" do
      game_id = UUID.uuid1()
      game = Game.new_game(game_id, 22)
      game = Game.new_game(game, 23)
      gameReturned = Game.make_move(game, 22, 3)

      assert_raise(RuntimeError, "Only current player can make a move!", fn ->
        Game.make_move(gameReturned, 22, 4)
      end)
  end

  test "player cannot make moves to already full column" do
    game_id = UUID.uuid1()
    p1 = 22 # red player
    p2 = 33 # yellow player
    game = Game.new_game(game_id, p1) |> Game.new_game(p2)

    gameReturned =
      Game.make_move(game, p1, 3)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 3)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 3)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 3)

    assert gameReturned.game_state == :playing
    assert gameReturned.current_player == :yellow
    assert Enum.at(gameReturned.board, 3) == [22, 33, 22, 33, 22, 33]
  end

  test "red player won horizontally" do
    p1 = 22
    p2 = 33
    game_id = UUID.uuid1()
    game = Game.new_game(game_id, p1) |> Game.new_game(p2)

    gameReturned =
      Game.make_move(game, p1, 3)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 3)
      |> Game.make_move(p2, 2)
      |> Game.make_move(p1, 4)
      |> Game.make_move(p2, 1)
      |> Game.make_move(p1, 5)

    assert gameReturned.game_state == { :win, :red}
  end

  test "yellow player won vertically" do
    p1 = 22
    p2 = 33
    game_id = UUID.uuid1()
    game = Game.new_game(game_id, p1) |> Game.new_game(p2)

    gameReturned =
      Game.make_move(game, p1, 3)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 4)
      |> Game.make_move(p2, 3)

    assert gameReturned.game_state == { :win, :yellow}
  end

  test "yellow player won diognally bottom right to up left ↖" do
    p1 = 22
    p2 = 33
    game_id = UUID.uuid1()
    game = Game.new_game(game_id, p1) |> Game.new_game(p2)

    gameReturned =
      Game.make_move(game, p1, 3)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 3)
      |> Game.make_move(p2, 1)
      |> Game.make_move(p1, 4)
      |> Game.make_move(p2, 5)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 2)
      |> Game.make_move(p1, 1)
      |> Game.make_move(p2, 4)

    assert gameReturned.game_state == { :win, :yellow}
  end

  test "yellow player won diognally bottom left to up right ↗" do
    p1 = 22
    p2 = 33
    game_id = UUID.uuid1()
    game = Game.new_game(game_id, p1) |> Game.new_game(p2)

    gameReturned =
      Game.make_move(game, p1, 3)
      |> Game.make_move(p2, 3)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 2)
      |> Game.make_move(p1, 2)
      |> Game.make_move(p2, 1)
      |> Game.make_move(p1, 1)
      |> Game.make_move(p2, 4)
      |> Game.make_move(p1, 4)
      |> Game.make_move(p2, 4)
      |> Game.make_move(p1, 5)
      |> Game.make_move(p2, 4)
      |> Game.make_move(p1, 5)
      |> Game.make_move(p2, 3)

    assert gameReturned.game_state == { :win, :yellow}
  end

  test "correct game server pid returned" do
    p1 = 22
    p2 = 33
    game_id = UUID.uuid1()
    {:ok, pid} = ConnectFour.Runtime.Server.start_link({game_id, p1, p2})
    {:ok, game_state} = ConnectFour.game_state(game_id)
    assert game_state.game_state == :playing
    assert game_state.players == %{ red: p1, yellow: p2}
    assert game_id = ConnectFour.game_id(pid)

    {:ok, game_pid} = ConnectFour.game_pid(game_id)
    assert game_pid == pid
  end
end
