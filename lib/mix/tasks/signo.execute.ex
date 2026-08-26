defmodule Mix.Tasks.Signo.Execute do
  @moduledoc """
  Compiles and runs a file using the `Signo` compiler.

      $ mix signo.execute hello.sg
      hello, world!

  """
  use Mix.Task

  alias Signo.Logger

  @impl true
  def run(_args = [path]) when is_binary(path) do
    Signo.eval_file!(path)
  rescue
    exception -> Logger.log_error(exception)
  end

  def run(_args) do
    IO.puts("Usage: mix signo.execute <PATH>")
    IO.puts("")
  end
end
