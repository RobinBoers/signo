defmodule Signo.String do
  @moduledoc """
  An extension of the standard library `String` module, providing
  various utilities to ease working with UTF-8 binary strings.
  """

  @doc """
  Pops the first character from a string
  """
  @spec pop_first(String.t()) :: {String.grapheme(), String.t()}
  def pop_first(string) when string != "" do
    String.split_at(string, 1)
  end
end
