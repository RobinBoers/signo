defmodule Mix.Tasks.Repl do
  @moduledoc """
  Starts a REPL (read-evaluate-print loop) session.

      $ mix repl
      Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:11:11] [ds:11:11:10] [async-threads:1] [jit]

      Interactive Signo v0.1.0 (Elixir/1.16.2)
      sig(1)> (print "hello world")
      hello world
      sig(2)>

  """
  use Mix.Task

  def run(_args) do
    Signo.repl()
  end
end
