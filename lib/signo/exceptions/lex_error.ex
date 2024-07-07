defmodule Signo.LexError do
  @moduledoc """
  Raised when the compiler finds an unexpected character or
  lexeme while tokenizing the source code.
  """
  defexception [:message, :lexeme, :pos]

  @impl true
  def exception(lexeme: lexeme, pos: pos) do
    %__MODULE__{
      message: "unexpected #{lexeme} at #{pos}",
      lexeme: lexeme,
      pos: pos
    }
  end
end
