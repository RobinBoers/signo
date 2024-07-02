defmodule Signo.REPL do
  @moduledoc false

  alias Signo.Env
  alias Signo.Position
  alias Signo.StdLib
  alias Signo.Logger

  @spec repl() :: no_return()
  def repl do
    IO.puts(erlang_info())
    IO.puts("Interactive Signo v#{Signo.version()} (#{elixir_info()})")

    StdLib.kernel()
    |> Env.new()
    |> repl()
  end

  defp erlang_info, do: :erlang.system_info(:system_version)
  defp elixir_info, do: "Elixir/#{System.version()}"

  @dialyzer {:nowarn_function, repl: 2}

  @spec repl(Env.t(), pos_integer()) :: no_return()
  defp repl(env, ln \\ 1) do
    env
    |> read(ln)
    |> eval(ln)
    |> print()
    |> repl(ln + 1)
  rescue
    exception -> print_error(exception) and repl(env, ln)
  end

  defp read(env, ln) do
    {IO.gets("sig(#{ln})> "), env}
  end

  defp eval({source, env}, ln) do
    eval(source, env, Position.new(:nofile, ln))
  end

  defp eval(source, env, pos) do
    source
    |> Signo.lex!(pos)
    |> Signo.parse!()
    |> Signo.evaluate!(env)
  end

  defp print({expression, env}) do
    Logger.log_expression(expression)
    env
  end

  defp print_error(exception) do
    Logger.log_error(exception)
    true # me too
  end
end
