defmodule Signo.Parser do
  @moduledoc false

  import Signo.AST, only: [is_value: 1]

  alias Signo.AST
  alias Signo.AST.Atom
  alias Signo.AST.List
  alias Signo.AST.Nil
  alias Signo.AST.Number
  alias Signo.AST.Quoted
  alias Signo.AST.String
  alias Signo.AST.Symbol
  alias Signo.ParseError
  alias Signo.Token

  @spec parse!([Token.t()]) :: AST.t()
  def parse!(tokens) do
    parse(tokens, [])
  end

  defp parse([%Token{type: :eof}], expressions) do
    %AST{expressions: Enum.reverse(expressions)}
  end

  defp parse(tokens, expressions) do
    {expression, rest} = parse_expression(tokens)
    parse(rest, [expression | expressions])
  end

  defp parse_expression([token | rest]) do
    case token do
      %Token{type: {:literal, value}} -> {parse_literal(value), rest}
      %Token{type: :symbol} -> {Symbol.new(token.lexeme, token.pos), rest}
      %Token{type: :quote} -> parse_quoted(rest)
      %Token{type: :opening} -> parse_list(rest, token.pos)
      _ -> raise ParseError, token
    end
  end

  defp parse_literal(value) do
    cond do
      is_number(value) -> Number.new(value)
      is_atom(value) -> Atom.new(value)
      is_binary(value) -> String.new(value)
    end
  end

  defp parse_quoted(tokens) do
    case parse_expression(tokens) do
      {value, rest} when is_value(value) -> {value, rest}
      {expression, rest} -> {Quoted.new(expression), rest}
    end
  end

  defp parse_list(tokens, collected \\ [], pos) do
    case tokens do
      [%Token{type: :closing} | rest] when collected == [] ->
        {Nil.new(), rest}

      [%Token{type: :closing} | rest] ->
        {collected |> Enum.reverse() |> List.new(pos), rest}

      [%Token{type: :eof} = token] ->
        raise ParseError, message: "unclosed list", token: token, pos: pos

      tokens ->
        {expression, rest} = parse_expression(tokens)
        parse_list(rest, [expression | collected], pos)
    end
  end
end
