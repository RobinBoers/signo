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

  ## Usage

  You'll mainly be using `compile_file!/1` and `compile_source!/1`, or
  a CLI abstraction of them, for compiling and interpreting your Signo source code.

  However, for more advanced usecases, we also expose individual compiler steps,
  such as `lex!/1`, `parse!/1`.
  """

  alias Signo.Token
  alias Signo.Lexer
  alias Signo.Parser

  @doc false
  def main(path \\ "main.sg"), do: compile_file!(path)

  @doc """
  Compiles and evaluates a Signo source file.

  ## Examples

      iex> Signo.compile_file!("./main.sg")
      hello, world!
      :ok

  """
  @spec compile_file!(Path.t()) :: :ok
  def compile_file!(path) do
    path
    |> File.read!()
    |> lex!(path)
    |> parse!()
  end

  @doc """
  Compiles and evaluates a string of Signo source code.

  ## Examples

      iex> Signo.compile_source!("(print 69)")
      69
      :ok

  """
  @spec compile_source!(String.t()) :: :ok
  def compile_source!(source) do
    source
    |> lex!()
    |> parse!()
  end

  @doc """
  Lexes a string containing valid Signo source code into
  a list of `Signo.Token`s.

  Raises `Signo.Lexer.LexingError` when encountering unknown characters.

  Multiple lines are supported.
  """
  @spec lex!(String.t()) :: [Token.t()]
  defdelegate lex!(source), to: Lexer

  @doc false
  @spec lex!(String.t(), Path.t()) :: [Token.t()]
  defdelegate lex!(source, path), to: Lexer

  @doc """
  Parses a list of `Signo.Token`s into a executable AST.

  Raises `Signo.ParseError` when encountering unexpected tokens.
  """
  @spec parse!([Token.t()]) :: :ok
  defdelegate parse!(tokens), to: Parser
end
