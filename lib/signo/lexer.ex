defmodule Signo.Lexer do
  @moduledoc false

  alias Signo.Position
  alias Signo.Token

  defmodule LexError do
    @moduledoc """
    Raised when the compiler finds an unexpected character or
    lexeme while tokenizing the source code.
    """
    defexception [:message, :lexeme, :pos]

    @impl true
    def exception(lexeme: lexeme, pos: pos) do
      %__MODULE__{
        message: "unexpected #{lexeme} at #{pos}",
        lexeme: lexeme,
        pos: pos
      }
    end
  end

  @whitespace ["\n", "\t", "\v", "\r", " "]
  @specials ["_", "=", "+", "-", "*", "/", "^", "%", "#", "&", "@", "!", "?", "~", "<", ">"]

  defguardp is_whitespace(ch) when ch in @whitespace
  defguardp is_special(ch) when ch in @specials
  defguardp is_digit(ch) when "0" <= ch and ch <= "9"
  defguardp is_lower(ch) when "a" <= ch and ch <= "z"
  defguardp is_upper(ch) when "A" <= ch and ch <= "Z"
  defguardp is_letter(ch) when is_lower(ch) or is_upper(ch)
  defguardp is_alnum(ch) when is_letter(ch) or is_digit(ch) or is_special(ch)
  defguardp is_semicolon(ch) when ch == ";"
  defguardp is_newline(ch) when ch == "\n"
  defguardp is_quote(ch) when ch == "\""
  defguardp is_minus(ch) when ch == "-"
  defguardp is_hash(ch) when ch == "#"
  defguardp is_dot(ch) when ch == "."

  @spec lex!(String.t(), Path.t()) :: [Token.t()]
  @spec lex!(String.t(), Position.t()) :: [Token.t()]
  def lex!(source, path_or_pos \\ %Position{})

  def lex!(source, path) when is_binary(path) do
    lex!(source, Position.new(path))
  end

  def lex!(source, pos = %Position{}) do
    source
    |> String.replace("\n\r", "\n")
    |> String.graphemes()
    |> lex(pos)
  end

  @spec lex([String.grapheme()], [Token.t()], Position.t()) :: [Token.t()]
  defp lex(chars, tokens \\ [], pos)

  defp lex(_chars = [], tokens, pos) do
    Enum.reverse([Token.new(:eof, "", pos) | tokens])
  end

  defp lex(chars = [ch | rest], tokens, pos) do
    cond do
      is_whitespace(ch) -> lex(rest, tokens, inc(pos, ch))
      is_semicolon(ch) -> ignore_comment(chars, tokens, pos)
      is_digit(ch) or is_minus(ch) -> read_number(chars, tokens, pos)
      is_quote(ch) -> read_string(chars, tokens, pos)
      is_hash(ch) -> read_identifier(chars, tokens, pos)
      is_alnum(ch) -> read_identifier(chars, tokens, pos)
      true -> read_next_char(chars, tokens, pos)
    end
  end

  defp ignore_comment(chars, tokens, pos) do
    {collected, rest} = Enum.split_while(chars, &(not is_newline(&1)))
    lex(rest, tokens, inc(pos, collected))
  end

  defp read_number(chars, tokens, pos) do
    {collected, rest} = collect_number(chars)
    lexeme = Enum.join(collected)
    token = Token.new({:literal, parse_number(lexeme)}, lexeme, pos)
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
      do: String.to_float(lexeme),
      else: String.to_integer(lexeme)
  end

  defp read_string([_quote | rest], tokens, pos) do
    {collected, [_quote | rest]} = Enum.split_while(rest, &(!is_quote(&1)))
    literal = Enum.join(collected)
    token = Token.new({:literal, literal}, "'#{literal}'", pos)

    # inc 2 more to account for the quotes
    lex(rest, [token | tokens], pos |> inc(collected) |> inc(2))
  end

  defp read_identifier(chars, tokens, pos) do
    {collected, rest} = Enum.split_while(chars, &is_alnum/1)
    lexeme = Enum.join(collected)
    token = Token.new(determine_type(lexeme), lexeme, pos)
    lex(rest, [token | tokens], inc(pos, collected))
  end

  defp determine_type("#" <> a),  do: {:literal, String.to_atom(a)}
  defp determine_type(_lexeme), do: :symbol

  defp read_next_char(_chars = [ch | rest], tokens, pos) do
    token =
      case ch do
        "(" -> Token.new(:opening, ch, pos)
        ")" -> Token.new(:closing, ch, pos)
        "'" -> Token.new(:quote, ch, pos)
        _ -> raise LexError, lexeme: ch, pos: pos
      end

    lex(rest, [token | tokens], inc(pos, ch))
  end

  defp inc(pos, c) when is_list(c), do: Position.increment(pos, c)
  defp inc(pos, c) when is_binary(c), do: Position.increment(pos, c)

  defp inc(pos, amount) when is_number(amount) do
    Enum.reduce(1..amount, pos, &Position.increment(&2, &1))
  end
end
