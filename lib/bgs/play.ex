defmodule Play do
  @moduledoc """
  Encapsulates the game rules
  """

  @doc """
  """
  def move(board, play) do
  end

  def possible_moves(board, play) do
    cond do
      can_double? ->
        [{:double}, {:roll}]
      board.cube_offered? ->
        [{:take}, [:drop]]
    end
  end

  @doc """
  """
  def can_double?(board, player) do
    board.turn == player && is_nil(board.dice) &&
      (is_nil(board.cube_owner) || board.cube_owner == player) &&
      !(board.crawford_match? && board.crawford_rule?)
  end

  @doc """
  """
  def can_bear_off?(board, player) do
    points = player_points(board, player)

    (for index <- (5..24), do: :array.get(index, points))
    |> Enum.sum == 0
  end

  defp player_points(board, :player1), do: board.points_player1
  defp player_points(board, :player2), do: board.points_player2
end
