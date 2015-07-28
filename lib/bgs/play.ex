defmodule BGS.Play do
  @moduledoc """
  Encapsulates the game rules
  """

  @type player :: :player1 | :player2
  @type play :: :roll | :double | :drop | :take | {:move, BGS.Move.t}

  @doc """
  Start a new match
  """
  @spec start_match(Map.t) :: BGS.Board.t
  def start_match(opts) do
    struct(BGS.Board, opts) |> start_new_game
  end

  def execute!(play, board, player) do
    case execute(play, board, player) do
      {:ok, board}              -> board
      {:error, :not_your_turn}  -> raise BGS.Play.NotYourTurnError
      {:error, reason}          -> raise BGS.Play.InvalidPlayError, reason
    end
  end

  @doc """
  """
  @spec execute(play, BGS.Board.t, player) :: BGS.Board.t
  def execute(play, board, player) do
    unless board.turn == player do
      {:error, :not_your_turn}
    else
      case do_execute(play, board, player) do
        {:error, reason}  -> {:error, reason}
        board             -> {:ok, board}
      end
    end
  end

  @spec do_execute(play, BGS.Board.t, player) :: BGS.Board.t
  defp do_execute(:double, board, player) do
    if can_double?(board, player) do
      struct(board, %{cube_offered?: true, turn: switch_player(player)})
    else
      {:error, :invalid_double}
    end
  end

  defp do_execute(:roll, board, _) do
    cond do
      board.cube_offered? ->
        {:error, :cube_offered}
      !is_nil(board.dices) ->
        {:error, :dices_rolled}
      true ->
        dices = BGS.Dice.roll
        %{board | dices: dices}
    end
  end

  defp do_execute(:take, board, player) do
    if board.cube_offered? do
      struct(board, %{
        cube_owner: player,
        cube: board.cube * 2,
        cube_offered?: false,
        turn: switch_player(player)})
    else
      {:error, :cube_not_offered}
    end
  end

  defp do_execute(:drop, board, player) do
    if board.cube_offered? do
      update_match_score(board, switch_player(player), board.cube)
      |> start_new_game
    else
      {:error, :cube_not_offered}
    end
  end

  # defp do_execute({:move, %BGS.Move{positions: positions}}, board, player) do
  # end

  def possible_moves(board, player) do
    cond do
      board.turn != player ->
        []
      can_double?(board, player) ->
        [{:double}, {:roll}]
      board.cube_offered? ->
        [{:take}, [:drop]]
      # !is_nil(board.dice) ->
      #   points = player_points(board, player)
    end
  end

  @doc """
  """
  def can_double?(board, player) do
    board.turn == player && is_nil(board.dices) &&
      (is_nil(board.cube_owner) || board.cube_owner == player) &&
      !board.cube_offered? &&
      !(board.crawford_match? && board.crawford_rule?)
  end

  @doc """
  Check if player can bear off

  ## Example

      iex> board =
  """
  def can_bear_off?(board, player) do
    points = player_points(board, player)

    (for index <- (5..24), do: points[index])
    |> Enum.sum == 0
  end

  @spec start_new_game(BGS.Board.t) :: BGS.Board.t
  defp start_new_game(board) do
    dices = {dice1, dice2} = BGS.Dice.non_double_roll
    turn = if dice1 > dice2 do :player1 else :player2 end

    struct(board, %{
      cube: nil,
      cube_offered?: false,
      cube_owner: nil,
      points_player1: BGS.Points.new(),
      points_player2: BGS.Points.new(),
      dices: dices,
      turn: turn
    })
  end

  @spec switch_player(player) :: player
  defp switch_player(player) do
    if player == :player1 do :player2 else :player1 end
  end

  @spec player_points(BGS.Board.t, player) :: BGS.Points
  defp player_points(board, :player1), do: board.points_player1
  defp player_points(board, :player2), do: board.points_player2

  @spec update_match_score(BGS.Board.t, player, non_neg_integer) :: BGS.Board.t
  defp update_match_score(board, player, points) do
    score_player = if player == :player1 do :score_player1 else :score_player2 end
    Map.put board, score_player, Map.get(board, score_player) + points
  end
end

defmodule BGS.Play.NotYourTurnError do
  @moduledoc """
  Raised when player tries play when it is not your turn
  """
  defexception [:message]
end

defmodule BGS.Play.InvalidPlayError do
  @moduledoc """
  Raised when player execute a inavlid play
  """
  defexception [:message]
end
