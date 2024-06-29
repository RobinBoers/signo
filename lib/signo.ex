defmodule Signo do
  @moduledoc """
  Signo is a Lisp-like language. That means it has two core concepts:

  - Atomics, which can be subdivided into three categories:

    - Literals, such as `100`, `1.0`, `true`, `"hello world"` and `3.0e10`.
    - References to previously defined variables or functions.
    - Operators: `<`, `<=`, `>`, `>=`, `==`, `!==`, `and`, `or`, `nor`, `xor`, `not`.

  - Lists, such as `("hello", 100, "worlds")`.

  As you can see, both of these are expressions. Because, in Signo, everything is an expression. A list can evaluate to another value when it starts with one of the following keywords:

  - `let` assigns a variable.
  - `if` branches, like this: `(if CONDITION THEN ELSE)`.
  - `def` defines a function, like this: `(NAME ARGUMENTS BODY)`.
  """

  alias Signo.Lexer

  def main(filename \\ "main.sg") do
    filename
    |> File.read!()
    |> lex!()
  end

  @doc """
  Converts a string containing valid Signo source code into
  a list of `Signo.Token`s.

  Raises `Signo.LexingError` when encountering unknown characters.

  Multiple lines are supported.
  """
  @spec lex!(String.t()) :: [Token.t()]
  defdelegate lex!(source), to: Lexer
end
