defmodule ConnectFour.Impl.Game do
  alias ConnectFour.Type
  alias ConnectFour.Impl.Rules

  @type t :: %ConnectFour.Impl.Game{
    game_id: String.t,
    game_state: Type.state,
    current_player: Type.player,
    players: map(),
    board: list(list(any()))
  }

  @board [
    [nil,nil,nil,nil,nil,nil],#1st column (left most is bottom)
    [nil,nil,nil,nil,nil,nil],#2nd column
    [nil,nil,nil,nil,nil,nil],
    [nil,nil,nil,nil,nil,nil],
    [nil,nil,nil,nil,nil,nil],
    [nil,nil,nil,nil,nil,nil],
    [nil,nil,nil,nil,nil,nil],
  ]

  defstruct(
    game_id: nil,
    game_state: nil,
    current_player: nil,
    players: %{red: nil, yellow: nil},
    board: @board
  )

  ################################

  @spec new_game(game_id :: String.t(), uid :: integer()) :: t()
  def new_game(game_id, uid) when is_binary(game_id) and is_integer(uid) do
    %ConnectFour.Impl.Game{
      game_id: game_id,
      current_player: :red,
      players: %{ red: uid, yellow: nil},
    }
  end

  def new_game(game_id, uid) when is_binary(game_id) , do: raise "Invalid user id passed #{uid}"

  @spec new_game(t(), integer()) :: t()
  def new_game(%__MODULE__{game_id: game_id, players: %{ red: red, yellow: nil}} = game, uid) when game_id != nil and is_integer(uid) do

      if uid == red do
        raise "User id must be different!"
      end
      %{ game | players: %{red: red, yellow: uid}, game_state: :playing}
  end

  def new_game(%__MODULE__{game_id: nil}, _uid), do: raise "Invalid game passed (no game_id)"
  def new_game(game, uid), do: raise "Invalid game or uid. game: #{inspect(game)} and uid: #{inspect(uid)}"

  # def new_game(game_id, uid) when is_integer(uid) , do: raise "Invalid game id passed #{inspect(game_id)}"

  ###############################################

  @spec play_again(t()) :: t()
  def play_again(game = %__MODULE__{}) do
      %{ game | game_state: :playing, current_player: get_other_player(game.current_player), board: @board }
  end

  ###############################################

  def make_move(%__MODULE__{game_state: game_state} = game, _uid, _col_index) when game_state in [{ :win, :red}, { :win, :yellow}, :draw], do: game

  def make_move(%__MODULE__{current_player: current_player, players: players, board: board} = game, uid, col_index) do

    unless players[current_player] == uid do
      raise "Only current player can make a move!"
    end
    unless is_integer(col_index) do
      raise "column_index must be an integer!"
    end

    col = Enum.at(board, col_index)
    updatedCol =
    case Enum.find_index(col, &(is_nil(&1))) do
      nil ->
        col
      index ->
        List.replace_at(col, index, get_player_by_uid(players, uid))
    end

    updatedBoard = List.replace_at(board, col_index, updatedCol)

    %{ game | board: updatedBoard, current_player: get_other_player(current_player), game_state: check_if_win_or_drawn(updatedBoard, players, uid)}
  end

  ######################################################

  defp check_if_win_or_drawn(board, players, uid) do
    case Rules.check_win(players, board, uid) do
      true -> {:win, get_player_by_uid(players, uid)}
      false ->
        if Rules.check_draw?(board) do
          :draw
        else
          :playing
        end
    end
  end

  def get_player_by_uid(players, uid) do
    Enum.find(players, fn {_k, v} -> v == uid end)
    |> elem(0)
  end

  defp get_other_player(:red), do: :yellow
  defp get_other_player(:yellow), do: :red
  defp get_other_player(player), do: raise "Unexpected player #{inspect(player)}"

end
