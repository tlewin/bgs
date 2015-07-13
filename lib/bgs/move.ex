defmodule BGS.Move do
  @moduledoc """
  Represent a full chequers move on board.
  """

  alias BGS.Move

  @type positions :: [tuple]

  @type t :: %__MODULE__ {
              positions: positions}

  defstruct positions: []

  @doc """
  Create a new move with empty position

  ## Example

      iex> BGS.Move.new
      %BGS.Move{positions: []}
      iex> BGS.Move.new([{8, 5}, {6, 5}])
      %BGS.Move{positions: [{8, 5}, {6, 5}]}
  """
  @spec new() :: t
  def new() do
    %Move{}
  end

  @spec new([tuple]) :: t
  def new(positions) do
    %Move{positions: positions}
  end

  @doc """
  Return the moviment in the compressed form.

  ## Example

      iex> BGS.Move.compressed(%BGS.Move{positions: [{24, 18}, {24, 18}, {13, 7}, {13, 7}]})
      %BGS.Move{positions: [{24, 18, 2}, {13, 7, 2}]}
      iex> BGS.Move.compressed(%BGS.Move{positions: [{24, 18, 1}, {24, 18}, {13, 7}, {13, 7}]})
      %BGS.Move{positions: [{24, 18, 2}, {13, 7, 2}]}
  """
  @spec compressed(t) :: t
  def compressed(%Move{positions: positions}) do
    positions
    |> Enum.reduce(%{}, fn(entry, acc) ->
      case entry do
        {from, to, times} ->
          Dict.update(acc, {from, to}, times, fn(value) -> value + times end)
        {from, to} ->
          Dict.update(acc, {from, to}, 1, fn(value) -> value + 1 end)
      end
    end)
    |> Enum.map(fn(item) ->
      {{from, to}, times} = item
      {from, to, times}
    end)
    |> sort
    |> new
  end

  @doc """
  Return the movement in expanded form.

  ## Example

      iex> BGS.Move.expanded(%BGS.Move{positions: [{24, 18, 2}, {13, 7, 2}]})
      %BGS.Move{positions: [{24, 18}, {24, 18}, {13, 7}, {13, 7}]}
      iex> BGS.Move.expanded(%BGS.Move{positions: [{24, 18, 1}, {13, 7, 3}]})
      %BGS.Move{positions: [{24, 18}, {13, 7}, {13, 7}, {13, 7}]}
  """
  @spec expanded(t) :: t
  def expanded(%Move{positions: positions}) do
    positions |> Enum.reduce([], fn
      {from, to, times}, acc ->
        acc ++ List.duplicate({from, to}, times)
      {from, to}, acc ->
        acc ++ [{from, to}]
    end)
    |> sort
    |> new
  end

  @doc """
  Return a move from string representation

  ## Example

    iex> BGS.Move.from_string "8/5 6/5"
    %BGS.Move{positions: [{8, 5}, {6, 5}]}
    iex> BGS.Move.from_string "8/5(2) 6/3(2)"
    %BGS.Move{positions: [{8, 5, 2}, {6, 3, 2}]}
  """
  @spec from_string(String.t) :: t
  def from_string(data) do
    Regex.scan(~r/(?<from>\d+)\/(?<to>\d+)\s?(\((?<times>\d+)\))?/, data, capture: ~w(from to times))
    |> Enum.map(fn
      [from, to, ""] -> {String.to_integer(from), String.to_integer(to)}
      [from, to, times] -> {String.to_integer(from), String.to_integer(to), String.to_integer(times)}
    end)
    |> sort
    |> new
  end

  @doc """
  Sort the move representation from highest point to the lowest

  ## Example

      iex> %BGS.Move{positions: [{6, 5}, {8, 5}]} |> BGS.Move.sort
      %BGS.Move{positions: [{8, 5}, {6, 5}]}
  """
  @spec sort(t) :: t
  def sort(%Move{positions: positions}) do
    positions |> sort |> new
  end

  @spec sort([tuple]) :: [tuple]
  def sort(positions) when is_list(positions) do
    positions
    |> Enum.sort(fn(pos1, pos2) ->
      t1 = {elem(pos1, 0), elem(pos1, 1)}
      t2 = {elem(pos2, 0), elem(pos2, 1)}
      t1 > t2
    end)
  end
end

defimpl String.Chars, for: BGS.Move do

  alias BGS.Move

  @doc """
  Convert a move to string format

  ## Example

      iex> BGS.Move{positions: [{8, 5}, {6, 5}]}
      "8/5 6/5"
      iex> BGS.Move{positions: [{8, 5, 2}, {6, 3, 2}]}
      "8/5(2) 6/3(2)"
  """
  @spec to_string(Move.t) :: String.t
  def to_string(move) do
    move
    |> Move.sort
    |> Map.get(:positions)
    |> Enum.map(fn
      {from, to, times} -> "#{from}/#{to}(#{times})"
      {from, to} -> "#{from}/#{to}"
    end)
    |> Enum.join " "
  end
end
