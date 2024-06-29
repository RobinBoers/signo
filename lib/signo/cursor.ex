defmodule Signo.Cursor do
  @moduledoc false
  use TypedStruct

  alias Signo.Token

  typedstruct enforce: true do
    field :source, [String.grapheme()]
    field :tokens, [Token.t()], default: []
    field :row, non_neg_integer(), default: 0
    field :col, non_neg_integer(), default: 0
  end

  @type char :: String.grapheme() | :eof

  @spec new(String.t()) :: t()
  def new(source) do
    %__MODULE__{
      source: String.graphemes(source),
    }
  end

  defguard is_done(cursor)
    when cursor.source == []

  @spec done?(t()) :: boolean()
  def done?(cursor) do
    is_done(cursor)
  end

  @spec peek(t()) :: char()
  def peek(cursor) do
    {_cursor, char} = next(cursor)
    char
  end

  @spec next(t()) :: {t(), char()}
  def next(cursor) when is_done(cursor) do
    {cursor, :eof}
  end

  def next(%{source: [char | source]} = cursor) do
    {cursor
     |> update_source(source)
     |> increment(char), char}
  end

  defp update_source(cursor, source) do
    %__MODULE__{cursor | source: source}
  end

  defp increment(c, :eof), do: c
  defp increment(c, "\n"), do: %__MODULE__{c | row: c.row + 1, col: 0}
  defp increment(c, _char), do: %__MODULE__{c | col: c.col + 1}

  @spec append(t(), Token.t()) :: t()
  def append(cursor, %Token{} = token) do
    %__MODULE__{cursor | tokens: [token | cursor.tokens]}
  end
end
