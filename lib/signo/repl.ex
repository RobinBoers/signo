defmodule Signo.REPL do
  @moduledoc false

  alias Signo.Env
  import IO.ANSI

  @spec repl(Env.t(), pos_integer()) :: no_return()
  def repl(env \\ %{}, ln \\ 1) do
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
    Signo.compile_source!(source)
    env
  end

  defp print(env) do
    IO.inspect(env)
  end

  defp log_error(exception) do
    IO.puts("#{red()}#{Exception.message(exception)}#{reset()}")
    # me too
    true
  end
end
