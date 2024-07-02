defmodule Signo do
  @moduledoc """
  Signo is a beautifully elegant Lisp-like language, written in Elixir.

  ## Language overview

  ### Atomics

  - Literals, such as `100`, `1.0`, `#true`, `"hello world"` and `#ok`.
  - References to previously defined variables or functions.
  - Keywords, like `let`, `if`, `def`, and `lambda`.

  ### Procedures

  Atomics can be grouped in space-seperated lists called procedures, like this:
  `(print "hello" 100 "worlds")`. What the procedure evaluates to is determinded
  based on the first atomic.

  - `(let $name $value)` puts a reference in scope, and returns the assigned value.
  - `(if $cond $then $else)` branches the control flow based on the given condition.
  - `(lambda $args $body)` evaluates to a callable function.
  - `(def $name $args $body)` is syntatic sugar for `(let $name (lambda $args $body))`.
  - `($name $args...)` calls a function and returns the evaluated body.

  In Signo, everything is an expression. That means every procedure evaluates to
  *something*, meaning blocks of expressions can be nested.

  Furthermore, Signo is entirely immutable. While a variable can be reassigned within
  scope, a reference to a variable can never be mutated and then used elsewhere.

  ## Usage

  You'll mainly be using `eval_file!/1` and `eval_source!/1`, or
  a CLI abstraction of them, for compiling and interpreting your Signo source code.

  However, for more advanced usecases, we also expose individual compiler steps,
  such as `lex!/1`, `parse!/1`, `evaluate!/1`.
  """

  alias Signo.Token
  alias Signo.Position
  alias Signo.Lexer
  alias Signo.Parser
  alias Signo.Interpreter
  alias Signo.Env
  alias Signo.AST
  alias Signo.REPL

  @doc """
  Returns the Signo version string.
  """
  @spec version() :: String.t()
  def version do
    :signo
    |> Application.spec(:vsn)
    |> to_string()
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

      iex> Signo.eval_file!("./main.sg")
      hello, world!
      %Signo.Env{...}

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

      iex> Signo.eval_source!("(print 69)")
      69
      %Signo.Env{...}

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
  @spec lex!(String.t(), Position.t()) :: [Token.t()]
  defdelegate lex!(source, path_or_pos), to: Lexer

  @doc """
  Parses a list of `Signo.Token`s into a executable AST.

  Raises `Signo.Parser.ParseError` when encountering unexpected tokens.
  """
  @spec parse!([Token.t()]) :: AST.t()
  defdelegate parse!(tokens), to: Parser

  @doc """
  Evaluates a `Signo.AST` into a `Signo.Env` containing final
  global scope, and executes any side-effects.

  See "Exceptions" for potential exceptions that can be raised.
  """
  @spec evaluate!(AST.t()) :: Env.t()
  defdelegate evaluate!(ast), to: Interpreter

  @doc """
  Same as `evaluate!/1`, but operates on an existing scope instead of
  intializing a new one.

  Primarily used to facilitate REPL-like programs, but can be applied
  in other contexts as well.
  """
  @spec evaluate!(AST.t(), Env.t()) :: Env.t()
  defdelegate evaluate!(env, ast), to: Interpreter
end
