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

defmodule Signo.ParseError do
  @moduledoc """
  Raised when the compiler encounters an unexpected token,
  or when a token is missing.
  """
  defexception [:message, :token]

  @impl true
  def exception(message: message, token: token, pos: pos) do
    %__MODULE__{
      message: "#{message} at #{pos}",
      token: token
    }
  end

  @impl true
  def exception(token) do
    %__MODULE__{
      message: "unexpected '#{token.lexeme}' at #{token.pos}",
      token: token
    }
  end
end

defmodule Signo.RuntimeError do
  @moduledoc """
  Raised when the compiler encounters *some* sort of error
  while evaluating the AST.
  """
  defexception [:message]

  @impl true
  def exception(message: message, position: pos) do
    %__MODULE__{message: "#{message} at #{pos}"}
  end
end

defmodule Signo.TypeError do
  @moduledoc """
  Raised when the compiler encounters mismatched types
  for a function.
  """
  defexception [:message]

  @impl true
  def exception(position: pos) do
    %__MODULE__{message: "mismatched types or mismatched number of arguments at #{pos}"}
  end
end

defmodule Signo.ReferenceError do
  @moduledoc """
  Raised when the interpreter tries to access a reference to
  a non-existant or undefined variable or function.
  """
  defexception [:message, :reference]

  @impl true
  def exception(reference: ref, position: pos) do
    %__MODULE__{
      message: "'#{ref}' is undefined at #{pos}",
      reference: ref
    }
  end
end