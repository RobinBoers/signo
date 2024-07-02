defmodule Signo.Logger do
  @moduledoc false

  import IO.ANSI

  @spec log_error(Exception.t()) :: :ok
  def log_error(exception) do
    exception
    |> format_error()
    |> red()
    |> IO.puts()
  end

  @spec log_expression(term()) :: :ok
  def log_expression(expression) do
    "#{expression}"
    |> blue()
    |> IO.puts()
  end

  defp format_error(exception) do
    "[#{error_name(exception)}] #{Exception.message(exception)}"
  end

  defp error_name(exception) do
    exception.__struct__
    |> Module.split()
    |> List.last()
  end

  defp red(str), do: red() <> str <> reset()
  defp blue(str), do: blue() <> str <> reset()
end
