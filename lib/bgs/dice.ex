defmodule BGS.Dice do
  @moduledoc """
  Methods for dice manipulation
  """

  @doc """
  roll the dices
  """
  @spec roll() :: {non_neg_integer, non_neg_integer}
  def roll() do
    {:random.uniform(6), :random.uniform(6)}
  end

  @doc """
  tests if it is a double

  ## Example

      iex> BGS.Dice.is_double?({3, 3})
      true
      iex> BGS.Dice.is_double?({5, 6})
      false
  """
  @spec is_double?({non_neg_integer, non_neg_integer}) :: boolean
  def is_double?({dice1, dice2}) do
    dice1 == dice2
  end

  @doc """
  Return non double roll
  """
  @spec non_double_roll() :: {non_neg_integer, non_neg_integer}
  def non_double_roll() do
    dices = roll()
    if is_double?(dices) do
      non_double_roll
    else
      dices
    end
  end
end
