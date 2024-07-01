defmodule Signo.Parser do
  @moduledoc false

  alias Signo.Token

  alias Signo.AST
  alias Signo.AST.{Literal, Symbol, Call, Block, Nil, If, Let, Lambda}

  defmodule ParseError do
    @moduledoc """
    Raised when the compiler encounters an unexpected token,
    or when a token is missing.
    """
    defexception [:message, :token]

    @impl true
    def exception(message) when is_binary(message) do
      %__MODULE__{message: message}
    end

    @impl true
    def exception(%Token{} = token) do
      %__MODULE__{
        message: "unexpected '#{token.lexeme}' at #{token.position}",
        token: token
      }
    end
  end

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
      %Token{type: {:literal, value}} -> {Literal.new(value), rest}
      %Token{type: :symbol, lexeme: ref} -> {Symbol.new(ref), rest}
      %Token{type: :opening} -> parse_list(rest)
      _ -> raise ParseError, token
    end
  end

  defp parse_list(tokens = [token | rest], collected \\ []) do
    case token do
      %Token{type: :closing} when collected == [] ->
        {Nil.new(), rest}

      %Token{type: :closing} ->
        {collected |> Enum.reverse() |> Call.new(), rest}

      %Token{type: {:keyword, :do}} when collected == [] ->
        {expression, rest} = parse_expression(rest)
        # TODO(find 0 or more expressions)
        expressions = [expression]
        {Block.new(expressions), rest}

      %Token{type: {:keyword, :if}} when collected == [] ->
        {condition, rest} = parse_expression(rest)
        {then, rest} = parse_expression(rest)
        {otherwise, rest} = maybe_parse_expression(rest)
        {_, rest} = expect(rest, :closing)

        {If.new(condition, then, otherwise), rest}

      %Token{type: {:keyword, :let}} when collected == [] ->
        {%Token{lexeme: ref}, rest} = expect(rest, :symbol)
        {expression, rest} = parse_expression(rest)
        {_, rest} = expect(rest, :closing)

        {Let.new(ref, expression), rest}

      %Token{type: {:keyword, :lambda}} when collected == [] ->
        {args, rest} = parse_arguments(rest)
        {body, rest} = parse_expression(rest)
        {_, rest} = expect(rest, :closing)

        {Lambda.new(args, body), rest}

      %Token{type: {:keyword, :def}} when collected == [] ->
        {%Token{lexeme: ref}, rest} = expect(rest, :symbol)
        {args, rest} = parse_arguments(rest)
        {body, rest} = parse_expression(rest)
        {_, rest} = expect(rest, :closing)

        {Let.new(ref, Lambda.new(args, body)), rest}

      _ ->
        {expression, rest} = parse_expression(tokens)
        parse_list(rest, [expression | collected])
    end
  end

  defp parse_arguments(tokens) do
    {_, rest} = expect(tokens, :opening)
    parse_arguments(rest, [])
  end

  defp parse_arguments([token | rest], collected) do
    case token do
      %Token{type: :closing} ->
        {Enum.reverse(collected), rest}

      %Token{type: :symbol, lexeme: ref} ->
        parse_arguments(rest, [Symbol.new(ref) | collected])

      _ ->
        raise ParseError, token
    end
  end

  defp maybe_parse_expression(tokens = [token | _]) do
    case token do
      %Token{type: :closing} -> {Nil.new(), tokens}
      _ -> parse_expression(tokens)
    end
  end

  defp expect([token | rest], type) do
    if token.type == type do
      {token, rest}
    else
      raise ParseError,
            "expected #{type}, but got: '#{token.lexeme}' at #{token.position}"
    end
  end
end
