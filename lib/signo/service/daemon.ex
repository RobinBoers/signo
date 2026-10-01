defmodule Signo.Daemon do
  @moduledoc """
  Signo can run as Interpreter as a Service.

      elixir --sname signo --cookie signo -S mix run --no-halt

  """

  @spec run(Path.t(), pid()) :: {:ok, non_neg_integer()} | {:error, term()}
  def run(path, caller) do
    # The group leader PID of the caller node is set as group leader
    # for this invocation. This ensures I/O (print, inspect, IO.gets)
    # operations are routed to the caller's terminal.
    Process.group_leader(self(), caller)
    Signo.eval_file!(path)

    {:ok, 0}
  rescue
    exception ->
      IO.puts(:stderr, Exception.format(:error, exception, __STACKTRACE__))
      {:ok, 1}
  end
end