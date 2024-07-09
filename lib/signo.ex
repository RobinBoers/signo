defmodule Signo do
  @moduledoc """
  Signo is a beautifully elegant Lisp-like language, written in Elixir.

  This module contains the public (Elixir) API for evaluating Signo programs. Check
  out the "Pages" tab in the left-hand corner for details on installing and running
  the interpreter, along with a detailed guide to the Signo language.

  You'll mainly be using `eval_file!/1` and `eval_source!/1`, or a CLI abstraction
  of them, for compiling and interpreting your Signo source code. However, for more
  advanced usecases, we also expose individual compiler steps, such as `lex!/1`,
  `parse!/1`, `evaluate!/1`.

  See "mix tasks" in the left-hand corner for details on command-line usage.
  """

  alias Signo.AST
  alias Signo.Compiler
  alias Signo.Env
  alias Signo.Interpreter
  alias Signo.Lexer
  alias Signo.Parser
  alias Signo.Position
  alias Signo.REPL
  alias Signo.Token

  @doc false
  def main do
    "(+ 1 (+ 2 3))"
    |> lex!()
    |> parse!()
    |> compile!()
  end

  @doc false
  @spec compile!(AST.t()) :: :ok
  defdelegate compile!(ast), to: Compiler

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
      {%AST.String{value: "hello world"}, %Signo.Env{...}}

  """
  @spec eval_file!(Path.t()) :: {AST.value(), Env.t()}
  def eval_file!(path) do
    path
    |> File.read!()
    |> lex!(path)
    |> parse!()
    |> evaluate!()
  end

  @doc false
  @spec eval_file!(Path.t(), Env.t()) :: {AST.value(), Env.t()}
  def eval_file!(path, env) do
    path
    |> File.read!()
    |> lex!(path)
    |> parse!()
    |> evaluate!(env)
  end

  @doc """
  Compiles and evaluates a string of Signo source code.

  ## Examples

      iex> Signo.eval_source!("(print 69)")
      69
      {%AST.Atom{value: :ok}, %Signo.Env{...}}

  """
  @spec eval_source!(String.t()) :: {AST.value(), Env.t()}
  def eval_source!(source) do
    source
    |> lex!()
    |> parse!()
    |> evaluate!()
  end

  @doc """
  Shorthand for `lex!/1` and `parse!/1`.

  Given a string of Signo source code, returns a valid
  AST that can be evaluated using `evaluate!/1`.

  ## Examples

      iex> evaluate!(~l"(print 10)")
      {%Signo.AST.Atom{value: :ok}, %Signo.AST.Env{}}

  """
  @spec sigil_l(String.t(), term()) :: AST.t()
  def sigil_l(source, []) do
    source
    |> lex!()
    |> parse!()
  end

  @doc false
  @spec sigil_L(String.t(), term()) :: AST.t()
  def sigil_L(source, mods), do: sigil_l(source, mods)

  @doc """
  Lexes a string containing valid Signo source code into
  a list of `Signo.Token`s.

  Raises `Signo.LexError` when encountering unknown characters.
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

  Raises `Signo.ParseError` when encountering unexpected tokens.
  """
  @spec parse!([Token.t()]) :: AST.t()
  defdelegate parse!(tokens), to: Parser

  @doc """
  Evaluates a `Signo.AST` into a `Signo.Env` containing final
  global scope, and executes any side-effects.

  See "Exceptions" for potential exceptions that can be raised.
  """
  @spec evaluate!(AST.t()) :: {AST.value(), Env.t()}
  defdelegate evaluate!(ast), to: Interpreter

  @doc """
  Same as `evaluate!/1`, but operates on an existing scope instead of
  intializing a new one.

  Primarily used to facilitate REPL-like programs, but can be applied
  in other contexts as well.
  """
  @spec evaluate!(AST.t(), Env.t()) :: {AST.value(), Env.t()}
  defdelegate evaluate!(ast, env), to: Interpreter
end
