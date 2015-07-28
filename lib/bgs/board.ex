defmodule BGS.Board do
  alias BGS.Points

  @type t :: %__MODULE__ {
            }

  defstruct points_player1: Points.new(),
            points_player2: Points.new(),
            bear_off_player1: 0,
            bear_off_player2: 0,
            dices: nil,
            cube: 1,
            cube_owner: nil,
            cube_offered?: false,
            clockwise?: false,
            match_to: 7,
            score_player1: 0,
            score_player2: 0,
            crawford_rule?: true,
            crawford_match?: false,
            jaccob_rule?: false,
            turn: nil

  @doc """
  Compute the pip count for each player
  """
  @spec pip_count(BGS.Board) :: {non_neg_integer, non_neg_integer}
  def pip_count(%BGS.Board{points_player1: points_p1, points_player2: points_p2}) do
    Enum.zip(points_p1, points_p2)
    |> Enum.reduce({1, {0, 0}}, fn {p1, p2}, {index, {pip1, pip2}} ->
      {index + 1, {pip1 + p1 * index, pip2 + p2 * index}}
    end)
    |> elem 1
  end
end

defimpl String.Chars, for: BGS.Board do
  @doc """
  Convert board to string format:

      +13-14-15-16-17-18------19-20-21-22-23-24-+     O: player1
      | X           O    |   | O              X |     0 points
      | X           O    |   | O              X |
      | X           O    |   | O                |
      | X                |   | O                |
      | X                |   | O                |
      |                  |BAR|                  |     7 point match (Cube: 1)
      | O                |   | X                |
      | O                |   | X                |
      | O           X    |   | X                |
      | O           X    |   | X              O |     Rolled 23
      | O           X    |   | X              O |     0 points
      +12-11-10--9--8--7-------6--5--4--3--2--1-+     X: player2
  """

  alias BGS.Points

  @spec to_string(BGS.Board) :: String.t
  def to_string(board) do
    # Generate a string representation of point
    num_points = Points.size(board.points_player1)
    points_to_string = (0..num_points - 2)
      |> Enum.map(fn index ->
        {p1, p2} = {board.points_player1[index], board.points_player2[23 - index]}
        if p1 > 0, do: point_stack("O", p1), else: point_stack("X", p2)
      end)
      # Append bar point to the end of the list
      |> Enum.concat([point_stack("O", board.points_player1[:bar]),
                      point_stack("X", board.points_player2[:bar])])
      |> List.to_tuple

    board_marks = if board.clockwise? do
      ["+24-23-22-21-20-19------18-17-16-15-14-13-+",
        "+-1--2--3--4--5--6-------7--8--9-10-11-12-+"]
    else
      ["+13-14-15-16-17-18------19-20-21-22-23-24-+",
        "+12-11-10--9--8--7-------6--5--4--3--2--1-+"]
    end

    # Top
    points_iterator = if board.clockwise?, do: (23..12), else: (12..23)
    top_board = board_half(points_to_string, points_iterator, 0..4, 24)

    # Middle
    middle_board = ["|                  |BAR|                  |"]

    # Bottom
    points_iterator = if board.clockwise?, do: (0..11), else: (11..0)
    bottom_board = board_half(points_to_string, points_iterator, 4..0, 25)

    board_marks
    |> Enum.intersperse(top_board ++ middle_board ++ bottom_board)
    |> List.flatten
    |> Enum.join("\n")
  end

  @spec point_stack(String.t, String.t) :: String.t
  defp point_stack(chequer_mark, stack_size) do
    if stack_size <= 5 do
      String.duplicate(chequer_mark, stack_size) <>
        String.duplicate(" ", 5 - stack_size)
    else
      String.duplicate(chequer_mark, 4) <>
      if stack_size <= 9 do
        Integer.to_string stack_size
      else
        <<?A - 10 + stack_size>>
      end
    end
  end

  @spec board_half(BGS.Points.t, Range.t, Range.t, Integer.t) :: List.t
  defp board_half(points, points_iterator, stack_iterator, bar_point) do
    stack_iterator |> Enum.map fn index ->
      (points_iterator |> Enum.reduce "|", fn point, acc ->
        acc <> " #{String.at elem(points, point), index} " <>
        # print bar point
        if String.length(acc) ==  16 do
          "| #{String.at elem(points, bar_point), index} |"
        else
          ""
        end
      end) <> "|"
    end
  end
end
