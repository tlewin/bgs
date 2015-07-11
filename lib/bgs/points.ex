defmodule BGS.Points do
  @doc """
  Represent the board points
  """

  alias BGS.Points

  @bar_point 24
  @initial_position :array.from_list(
    [0, 0, 0, 0, 0, 5,
     0, 3, 0, 0, 0, 0,
     5, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 2,
     0] # Bar point
    )

  defstruct points: @initial_position

  def new() do
    %Points{}
  end

  def put(%Points{points: points}, key, value) do
    %Points{points: :array.set(key, value, points)}
  end

  def get(%Points{points: points}, key) do
    :array.get(key, points)
  end

  def size(%Points{points: points}) do
    :array.size(points)
  end
end

defimpl Access, for: BGS.Points do
  def get(points, index) do
    case index do
      :bar ->
        BGS.Points.get(points, 24)
      _ ->
        BGS.Points.get(points, index)
    end
  end

  def get_and_update(points, index, fun) do
    {get, update} = fun.(BGS.Points.get(points, index))
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

