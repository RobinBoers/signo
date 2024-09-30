defmodule Signo.Position do
  @moduledoc """
  Records the position of a character or token in the original source code.
  """
  use TypedStruct

  @type path :: Path.t() | :nofile

  typedstruct enforce: true do
    field :path, path(), default: :nofile
    field :row, non_neg_integer(), default: 1
    field :col, non_neg_integer(), default: 1
  end

  @spec new(path()) :: t()
  def new(path) when is_binary(path) or path == :nofile do
    %__MODULE__{path: path}
  end

  @spec new(path(), number()) :: t()
  def new(path, row) when is_number(row) do
    %__MODULE__{new(path) | row: row}
  end

  @doc """
  Updates the recorded pos given either a single grapheme,
  or a collected list of graphemes.
  """
  @spec increment(t(), [String.grapheme()]) :: t()
  def increment(pos, lexeme) when is_list(lexeme) do
    Enum.reduce(lexeme, pos, &increment(&2, &1))
  end

  @spec increment(t(), String.grapheme()) :: t()
  def increment(pos, "\n"), do: %__MODULE__{pos | row: pos.row + 1, col: 1}
  def increment(pos, _chr), do: %__MODULE__{pos | col: pos.col + 1}

  defimpl String.Chars do
    def to_string(%@for{} = pos) do
      "#{pos.path}:#{pos.row}:#{pos.col}"
    end
  end
end
