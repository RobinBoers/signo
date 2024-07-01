defmodule Signo.Lexer do
  @moduledoc false

  alias Signo.Position
  alias Signo.Token

  defmodule LexError do
    @moduledoc """
    Raised when the compiler finds an unexpected character or
    lexeme while tokenizing the source code.
    """
    defexception [:message, :lexeme, :position]

    @impl true
    def exception(lexeme: lexeme, position: pos) do
      %__MODULE__{
        message: "unexpected #{lexeme} at #{pos}",
        lexeme: lexeme,
        position: pos
      }
    end
  end

  @keywords ["if", "let", "def", "lambda"]
  @whitespace ["\n", "\t", "\v", "\r", " "]
  @specials ["_", "=", "+", "-", "*", "/", "^", "%", "#", "&", "@", "!", "~", "<", ">"]

  defguardp is_whitespace(ch) when ch in @whitespace
  defguardp is_special(ch) when ch in @specials
  defguardp is_lower(ch) when "a" <= ch and ch <= "z"
  defguardp is_upper(ch) when "A" <= ch and ch <= "Z"
  defguardp is_letter(ch) when is_lower(ch) or is_upper(ch) or is_special(ch)
  defguardp is_digit(ch) when "0" <= ch and ch <= "9"
  defguardp is_quote(ch) when ch == "'"
  defguardp is_hash(ch) when ch == "#"
  defguardp is_dot(ch) when ch == "."

  @spec lex!(String.t(), Position.path()) :: [Token.t()]
  def lex!(source, path \\ :nofile) do
    source
    |> String.replace("\n\r", "\n")
    |> String.graphemes()
    |> lex(Position.new(path))
  end

  @spec lex([String.grapheme()], [Token.t()], Position.t()) :: [Token.t()]
  defp lex(chars, tokens \\ [], pos)

  defp lex(_chars = [], tokens, pos) do
    Enum.reverse([Token.new(:eof, "", pos) | tokens])
  end

  defp lex(chars = [ch | rest], tokens, pos) do
    cond do
      is_whitespace(ch) -> lex(rest, tokens, inc(pos, ch))
      is_hash(ch) -> read_atom(chars, tokens, pos)
      is_letter(ch) -> read_identifier(chars, tokens, pos)
      is_digit(ch) -> read_number(chars, tokens, pos)
      is_quote(ch) -> read_string(chars, tokens, pos)
      true -> read_next_char(chars, tokens, pos)
    end
  end

  defp read_atom(chars, tokens, pos) do
    {collected, rest} = Enum.split_while(chars, &is_letter/1)
    lexeme = Enum.join(collected)
    literal = lexeme |> String.slice(1..-1//1) |> String.to_atom()

    token = Token.new({:literal, literal}, lexeme, pos)
    lex(rest, [token | tokens], inc(pos, collected))
  end

  defp read_identifier(chars, tokens, pos) do
    {collected, rest} = Enum.split_while(chars, &is_letter/1)
    lexeme = Enum.join(collected)

    token = Token.new(ckeck_keyword(lexeme), lexeme, pos)
    lex(rest, [token | tokens], inc(pos, collected))
  end

  defp ckeck_keyword(lexeme) do
    if lexeme in @keywords,
      do: {:keyword, String.to_atom(lexeme)},
      else: :symbol
  end

  defp read_number(chars, tokens, pos) do
    {collected, rest} = collect_number(chars)
    lexeme = Enum.join(collected)
    {literal, ""} = parse_number(lexeme)

    token = Token.new({:literal, literal}, lexeme, pos)
    lex(rest, [token | tokens], inc(pos, collected))
  end

  defp collect_number(chars = [ch | rest], collected \\ []) do
    cond do
      is_dot(ch) and "." in collected -> {Enum.reverse(collected), chars}
      is_digit(ch) or is_dot(ch) -> collect_number(rest, [ch | collected])
      true -> {Enum.reverse(collected), chars}
    end
  end

  defp parse_number(lexeme) do
    if String.contains?(lexeme, "."),
      do: Float.parse(lexeme),
      else: Integer.parse(lexeme)
  end

  defp read_string([_quote | rest], tokens, pos) do
    {collected, [_quote | rest]} = Enum.split_while(rest, &(!is_quote(&1)))
    literal = Enum.join(collected)
    token = Token.new({:literal, literal}, "'#{literal}'", pos)

    # inc 2 more to account for the quotes
    lex(rest, [token | tokens], pos |> inc(collected) |> inc(2))
  end

  defp read_next_char(_chars = [ch | rest], tokens, pos) do
    token =
      case ch do
        "(" -> Token.new(:opening, ch, pos)
        ")" -> Token.new(:closing, ch, pos)
        _ -> raise LexError, lexeme: ch, position: pos
      end

    lex(rest, [token | tokens], inc(pos, ch))
  end

  defp inc(pos, c) when is_list(c), do: Position.increment(pos, c)
  defp inc(pos, c) when is_binary(c), do: Position.increment(pos, c)

  defp inc(pos, amount) when is_number(amount) do
    Enum.reduce(1..amount, pos, &Position.increment(&2, &1))
  end
end
