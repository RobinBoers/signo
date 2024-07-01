defmodule Signo.REPL do
  @moduledoc false

  alias Signo.Env
  import IO.ANSI

  @spec repl() :: no_return()
  def repl do
    IO.puts(erlang_info())
    IO.puts("Interactive Signo v#{Signo.version()} (#{elixir_info()})")
    repl(%Env{})
  end

  defp erlang_info, do: :erlang.system_info(:system_version)
  defp elixir_info, do: "Elixir/#{System.version()}"

  @spec repl(Env.t(), pos_integer()) :: no_return()
  defp repl(env, ln \\ 1) do
    env
    |> read(ln)
    |> eval()
    |> print()
    |> repl(ln + 1)
  rescue
    exception -> log_error(exception) and repl(env, ln)
  end

  defp read(env, ln) do
    {IO.gets("sig(#{ln})> "), env}
  end

  defp eval({source, env}) do
    source
    |> Signo.lex!()
    |> Signo.parse!()
    |> Signo.evaluate!(env)
  end

  defp print(env) do
    IO.inspect(env)
  end

  defp log_error(exception) do
    IO.puts("#{red()}#{Exception.message(exception)}#{reset()}")
    true # me too
  end
end
