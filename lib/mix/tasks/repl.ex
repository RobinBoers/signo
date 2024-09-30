defmodule Mix.Tasks.Repl do
  @moduledoc """
  Starts a REPL (read-evaluate-print loop) session.

      $ mix repl
      Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:11:11] [ds:11:11:10] [async-threads:1] [jit]

      Interactive Signo v0.1.0 (Elixir/1.16.2)
      sig(1)> (print "hello world")
      hello world
      #ok
      sig(2)>

  Turns out Elixir and Erlang make something as simple as a readline *a fucking nightmare*
  to implement. So if you want a decent typing experience, consider installing
  [rlwrap](https://github.com/hanslub42/rlwrap) and running the REPL like this:

      rlwrap mix repl

  """
  use Mix.Task

  @impl true
  def run(_args) do
    Signo.repl()
  end
end
