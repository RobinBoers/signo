defmodule Mix.Tasks.Repl do
  @moduledoc false
  use Mix.Task

  def run(_) do
    IO.puts(erlang_info())
    IO.puts("Interactive Signo v#{Signo.version()} (#{elixir_info()})")
    Signo.repl()
  end

  def erlang_info, do: :erlang.system_info(:system_version)
  def elixir_info, do: "Elixir/#{System.version()}"
end
