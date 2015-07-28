defmodule BGS.Points do
  @doc """
  Represent the board points
  """

  alias BGS.Points

  @type points :: array

  @type t :: %__MODULE__ {
              points: points}

  @bar_point 24
  @initial_position :array.from_list(
    [0, 0, 0, 0, 0, 5,
     0, 3, 0, 0, 0, 0,
     5, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 2,
     0] # Bar point
    )

  defstruct points: @initial_position

  @doc """
  Return a board points representation

  ## Example

      iex> BGS.Points.new
      %BGS.Points{}
  """
  @spec new() :: t
  def new() do
    %Points{}
  end

  @spec new(List.t) :: t
  def new(points) when is_list(points) do
    unless List.size(points) == 25 do
    end
  end

  @doc """
  TODO: insert function guards
  """
  @spec put(t, integer, integer) :: t
  def put(%Points{points: points}, key, value) do
    %Points{points: :array.set(key, value, points)}
  end

  @spec get(t, integer | atom) :: integer
  def get(%Points{points: points}, key) do
    case key do
      :bar ->
        :array.get(key, 24)
      _ ->
        :array.get(key, points)
    end
  end

  @spec size(t) :: t
  def size(%Points{points: points}) do
    :array.size(points)
  end
end

defimpl Access, for: BGS.Points do
  alias BGS.Points

  @spec get(Points.t, integer | atom) :: integer
  def get(points, index) do
    Points.get(points, index)
  end

  @spec get_and_update(Points.t, integer | atom, (integer -> integer)) :: integer
  def get_and_update(points, index, fun) do
    {get, update} = fun.(Points.get(points, index))
    {get, Points.put(points, index, update)}
  end
end

defimpl Enumerable, for: BGS.Points do
  def count(points) do
    {:ok, BGS.Points.size(points)}
  end

  def member?(points, value) do
    {:error, __MODULE__}
  end

  def reduce(points, acc, fun) do
    last = BGS.Points.size(points) - 1
    reduce(points, 0, acc, fun, Range.Iterator.next(0, 0..last), last)
  end

  defp reduce(points, _index, {:halt, acc}, _fun, _next, size) do
    {:halted, acc}
  end

  defp reduce(points, index, {:suspend, acc}, fun, next, size) do
    {:suspended, acc, &reduce(points, index, &1, fun, next, size)}
  end

  defp reduce(points, index, {:cont, acc}, fun, next, size) when index <= size do
    reduce(points, next.(index), fun.(points[index], acc), fun, next, size)
  end

  defp reduce(_, _, {:cont, acc}, _fun, _next, size) do
    {:done, acc}
  end
end
