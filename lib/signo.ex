defmodule Signo do
  @moduledoc """
  Signo is a beautifully elegant Lisp-like language, written in Elixir.

  ## Language overview

  Signo is a Lisp-like language. It has two core concepts:

  ### Atomics

  - Literals, such as `100`, `1.0`, `#true`, `"hello world"` and `#ok`.
  - References to previously defined variables or functions.

  ### Lists

  Space-seperated lists containing atomics, like this: `("hello" 100 "worlds")`.

  As you can see, both of these are expressions. Because, in Signo, everything is an
  expression. A list can evaluate to another value when it starts with one of the
  following keywords:

  - `(let $name $value)` puts a reference in scope, and returns the assigned value.
  - `(if $cond $then $else)` branches the control flow based on the given condition.

  Furthermore, Signo is entirely immutable. While a variable can be reassigned within
  scope, a reference to a variable can never be mutated and then used elsewhere.

  ### Functions

  `(lambda $args $body)` evaluates to a callable function. A function is automatically
  called when it's the first expression in a list: `((lambda (n) (* n 2)), 3)`
  (would evaluate to `6`).

  Functions can be bound to variable names, just like any other expression:

      (let double (lambda (n) (* n 2)))
      (double 3)

  Because this is such a common construct, Signo has some syntatic sugar for it:

      (def double (n) (* n 2))
      (double 3)

  ## Usage

  You'll mainly be using `eval_file!/1` and `eval_source!/1`, or
  a CLI abstraction of them, for compiling and interpreting your Signo source code.

  However, for more advanced usecases, we also expose individual compiler steps,
  such as `lex!/1`, `parse!/1`, `evaluate!/1`.
  """

  alias Signo.Token
  alias Signo.Lexer
  alias Signo.Parser
  alias Signo.Interpreter
  alias Signo.AST
  alias Signo.REPL

  @doc false
  def main(path \\ "main.sg"), do: eval_file!(path)

  @spec version() :: String.t()
  def version do
    Mix.Project.config()[:version]
  end

  @doc """
  Starts a REPL (read-evaluate-print loop) session.

  ## Examples

      Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:11:11] [ds:11:11:10] [async-threads:1] [jit]

      Interactive Signo v0.1.0 (Elixir/1.16.2)
      sig(1)> (print "hello world")
      hello world
      sig(2)>

  """
  defdelegate repl, to: REPL

  @doc """
  Compiles and evaluates a Signo source file.

  ## Examples

      iex> Signo.compile_file!("./main.sg")
      hello, world!
      :ok

  """
  @spec eval_file!(Path.t()) :: Env.t()
  def eval_file!(path) do
    path
    |> File.read!()
    |> lex!(path)
    |> parse!()
    |> evaluate!()
  end

  @doc """
  Compiles and evaluates a string of Signo source code.

  ## Examples

      iex> Signo.compile_source!("(print 69)")
      69
      :ok

  """
  @spec eval_source!(String.t()) :: Env.t()
  def eval_source!(source) do
    source
    |> lex!()
    |> parse!()
    |> evaluate!()
  end

  @doc """
  Lexes a string containing valid Signo source code into
  a list of `Signo.Token`s.

  Raises `Signo.Lexer.LexError` when encountering unknown characters.
  Multiple lines are supported.
  """
  @spec lex!(String.t()) :: [Token.t()]
  defdelegate lex!(source), to: Lexer

  @doc false
  @spec lex!(String.t(), Path.t()) :: [Token.t()]
  defdelegate lex!(source, path), to: Lexer

  @doc """
  Parses a list of `Signo.Token`s into a executable AST.

  Raises `Signo.Parser.ParseError` when encountering unexpected tokens.
  """
  @spec parse!([Token.t()]) :: AST.t()
  defdelegate parse!(tokens), to: Parser

  @doc """
  Evaluates a `Signo.AST` into a `Signo.Env` containing final
  global scope, and executes any side-effects.

  Raises `Signo.Interpreter.TypeError` when encountering type errors.
  """
  @spec evaluate!(AST.t()) :: Env.t()
  defdelegate evaluate!(ast), to: Interpreter

  @doc """
  Same as `evaluate!/1`, but operates on an existing scope instead of
  intializing a new one.

  Primarily used to facilitate REPL-like programs, but can be applied
  in other contexts as well.
  """
  @spec evaluate!(Env.t(), AST.t()) :: Env.t()
  defdelegate evaluate!(env, ast), to: Interpreter
end
