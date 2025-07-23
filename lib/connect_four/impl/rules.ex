defmodule ConnectFour.Impl.Rules do
  @moduledoc """
  Game rules for Connect Four:
  - Board is a list of 7 columns, each with 6 cells (bottom-up).
  - Each cell contains a user ID (integer) or `nil`.
  """
  import ConnectFour.Impl.Game, only: [get_player_by_uid: 2]

  @cols 7
  @rows 6
  @win_length 4

  @spec check_win(players :: list, board :: list, user_id :: integer) :: boolean
  def check_win(players, board, user_id) do
    positions = for col <- 0..@cols - 1, row <- 0..@rows - 1, do: {col, row}

    Enum.any?(positions, fn {c, r} ->
      check_dir(board, c, r, 1, 0, get_player_by_uid(players, user_id)) or  # ➡ right (horizontal)
      check_dir(board, c, r, 0, 1, get_player_by_uid(players, user_id)) or  # ⬆ up (vertical)
      check_dir(board, c, r, 1, 1, get_player_by_uid(players, user_id)) or  # ↗ up-right (diagonal)
      check_dir(board, c, r, -1, 1, get_player_by_uid(players, user_id))    # ↖ up-left (diagonal)
    end)
  end

  defp check_dir(board, c, r, dc, dr, user_id) do
    Enum.all?(0..@win_length - 1, fn i ->
      nc = c + dc * i
      nr = r + dr * i
      in_bounds?(nc, nr) and get_cell(board, nc, nr) == user_id
    end)
  end

  defp get_cell(board, c, r) do
    board
    |> Enum.at(c)
    |> then(fn col -> Enum.at(col, r) end)
  end

  defp in_bounds?(c, r), do: c in 0..(@cols - 1) and r in 0..(@rows - 1)

  @spec check_draw?(board :: list) :: boolean
  def check_draw?(board) do
    Enum.all?(board, fn col -> Enum.all?(col, &(&1 != nil)) end)
  end
end
