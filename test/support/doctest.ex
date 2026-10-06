defmodule Signo.DocTest do
  @moduledoc """
  Extract test cases from the Signo documentation.
  """

  import ExUnit.CaptureIO, only: [with_io: 1]

  alias Signo.AST.Atom
  alias Signo.Env
  alias Signo.Position
  alias Signo.StdLib

  @prompt ~r/^(\s*)sig> (.*)$/
  @hidden :"do not show this result in output"

  defmacro doctest_sig(module) do
    module = Macro.expand(module, __CALLER__)

    for {name, arity, groups} <- extract(module), {group, i} <- Enum.with_index(groups, 1) do
      quote do
        test unquote("#{inspect(module)}.#{name}/#{arity} (#{i})") do
          Signo.DocTest.run(unquote(Macro.escape(group)))
        end
      end
    end
  end

  @doc false
  def extract(module) do
    {:docs_v1, _, _, _, _, _, docs} = Code.fetch_docs(module)

    for {{:function, name, arity}, _, _, %{"en" => doc}, _} <- docs,
        groups = parse(doc),
        groups != [] do
      {name, arity, groups}
    end
  end

  defp parse(doc) do
    doc
    |> String.split("\n")
    |> Enum.chunk_by(&(String.trim(&1) == ""))
    |> Enum.filter(fn lines -> Enum.any?(lines, &Regex.match?(@prompt, &1)) end)
    |> Enum.map(&parse_group/1)
  end

  defp parse_group(lines) do
    {examples, _indent} =
      lines
      |> Enum.drop_while(&(not Regex.match?(@prompt, &1)))
      |> Enum.reduce({[], nil}, &parse_line/2)

    examples
    |> Enum.reverse()
    |> Enum.map(fn {source, expected} -> {source, Enum.reverse(expected)} end)
  end

  defp parse_line(line, {examples, indent}) do
    case Regex.run(@prompt, line) do
      [_, indent, source] -> {[{source, []} | examples], indent}
      nil -> {add_line(examples, line, indent), indent}
    end
  end

  defp add_line([{source, []} | rest], line, indent) do
    if String.starts_with?(line, indent <> " "),
      do: [{source <> "\n" <> String.trim(line), []} | rest],
      else: [{source, [trim(line, indent)]} | rest]
  end

  defp add_line([{source, expected} | rest], line, indent) do
    [{source, [trim(line, indent) | expected]} | rest]
  end

  defp trim(line, indent) do
    line |> String.replace_prefix(indent, "") |> String.trim_trailing()
  end

  @doc false
  def run(examples) do
    examples
    |> Enum.with_index(1)
    |> Enum.reduce(Env.new(StdLib.kernel()), fn {{source, expected}, ln}, env ->
      {actual, env} = eval(source, env, ln)

      unless matches?(expected, actual) do
        raise ExUnit.AssertionError,
          message: "Doctest failed",
          expr: "sig> " <> source,
          left: Enum.join(actual, "\n"),
          right: Enum.join(expected, "\n")
      end

      env
    end)
  end

  defp eval(source, env, ln) do
    {{result, env}, stdout} =
      with_io(fn ->
        try do
          {value, env} =
            source
            |> Signo.lex!(Position.new(:nofile, ln))
            |> Signo.parse!()
            |> Signo.evaluate!(env)

          {format(value), env}
        rescue
          exception -> {format_error(exception), env}
        end
      end)

    {String.split(stdout, "\n", trim: true) ++ List.wrap(result), env}
  end

  defp format(%Atom{value: @hidden}), do: nil
  defp format(value), do: inspect(value)

  defp format_error(exception) do
    name = exception.__struct__ |> Module.split() |> List.last()
    "[#{name}] #{Exception.message(exception)}"
  end

  defp matches?(expected, actual) when length(expected) == length(actual) do
    expected
    |> Enum.zip(actual)
    |> Enum.all?(fn {e, a} ->
      if String.ends_with?(e, "..."),
        do: String.starts_with?(a, String.trim_trailing(e, "...")),
        else: e == a
    end)
  end

  defp matches?(_, _), do: false
end
