defmodule Signo.Location do
  @moduledoc """
  Records the position of a character or token in the original source code.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :row, non_neg_integer(), default: 0
    field :col, non_neg_integer(), default: 0
  end

  @spec increment(t(), [String.grapheme()] | String.grapheme()) :: t()
  def increment(loc, lexeme) when is_list(lexeme) do
    Enum.reduce(lexeme, loc, &increment(&2, &1))
  end

  def increment(loc, "\n"), do: %__MODULE__{loc | row: loc.row + 1, col: 0}
  def increment(loc, _chr), do: %__MODULE__{loc | col: loc.col + 1}
end
