defmodule Signo.Position do
  @moduledoc """
  Records the position of a character or token in the original source code.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :path, String.t(), default: "internal"
    field :row, non_neg_integer(), default: 0
    field :col, non_neg_integer(), default: 0
  end

  @doc """
  Updates the recorded position given either a single grapheme,
  or a collected list of graphemes.
  """
  @spec increment(t(), String.grapheme() | [String.grapheme()]) :: t()
  def increment(pos, lexeme) when is_list(lexeme) do
    Enum.reduce(lexeme, pos, &increment(&2, &1))
  end

  def increment(pos, "\n"), do: %__MODULE__{pos | row: pos.row + 1, col: 0}
  def increment(pos, _chr), do: %__MODULE__{pos | col: pos.col + 1}
end

defimpl String.Chars, for: Signo.Position do
  def to_string(%Signo.Position{} = pos) do
    "#{pos.path}:#{pos.row}:#{pos.col}"
  end
end
