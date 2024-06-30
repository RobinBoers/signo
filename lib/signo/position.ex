defmodule Signo.Position do
  @moduledoc """
  Records the position of a character or token in the original source code.
  """
  use TypedStruct

  @type location :: Path.t() | :runtime

  typedstruct enforce: true do
    field :path, location(), default: :runtime
    field :row, non_neg_integer(), default: 1
    field :col, non_neg_integer(), default: 1
  end

  @doc """
  Constructs a new `Signo.Position`.
  """
  @spec new(location()) :: t()
  def new(path) when is_binary(path) or path == :runtime do
    %__MODULE__{path: path}
  end

  @doc """
  Updates the recorded position given either a single grapheme,
  or a collected list of graphemes.
  """
  @spec increment(t(), [String.grapheme()]) :: t()
  def increment(pos, lexeme) when is_list(lexeme) do
    Enum.reduce(lexeme, pos, &increment(&2, &1))
  end

  @spec increment(t(), String.grapheme()) :: t()
  def increment(pos, "\n"), do: %__MODULE__{pos | row: pos.row + 1, col: 1}
  def increment(pos, _chr), do: %__MODULE__{pos | col: pos.col + 1}
end

defimpl String.Chars, for: Signo.Position do
  def to_string(%Signo.Position{} = pos) do
    "#{pos.path}:#{pos.row}:#{pos.col}"
  end
end
