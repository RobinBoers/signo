defmodule Signo.Lexer do
  @moduledoc false

  alias Signo.Position
  alias Signo.Token

  import Signo.Position, only: [increment: 2]

  defmodule LexingError do
    @moduledoc """
    Raised when the compiler finds an unexpected lexeme while
    tokenizing the source code.
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

  @keywords ["if", "let", "def"]
  @special ["_", "=", "+", "-", "*", "/", "^", "%", "&", "@", "#", "!", "~", "<", ">"]

  @spec lex!(String.t()) :: [Token.t()]
  def lex!(source) do
    source
    |> String.replace("\n\r", "\n")
    |> String.graphemes()
    |> lex()
  end

  @spec lex([String.grapheme()], [Token.t()], Position.t()) :: [Token.t()]
  defp lex(chars, tokens \\ [], pos \\ %Position{})

  defp lex(_chars = [], tokens, pos) do
    Enum.reverse([Token.new(:eof, "", pos) | tokens])
  end

  defp lex(chars = [ch | rest], tokens, pos) do
    cond do
      is_whitespace(ch) -> lex(rest, tokens, pos)
      is_letter(ch) -> read_identifier(chars, tokens, pos)
      is_digit(ch) -> read_number(chars, tokens, pos)
      is_quote(ch) -> read_string(chars, tokens, pos)
      true -> read_next_char(chars, tokens, pos)
    end
  end

  defp read_identifier(chars, tokens, pos) do
    {collected, rest} = Enum.split_while(chars, &is_letter/1)
    lexeme = Enum.join(collected)

    token = Token.new(ckeck_keyword(lexeme), lexeme, pos)
    lex(rest, [token | tokens], increment(pos, collected))
  end

  defp ckeck_keyword(lexeme) do
    if lexeme in @keywords do
      {:keyword, String.to_existing_atom(lexeme)}
    else
      :symbol
    end
  end

  defp read_number(chars, tokens, pos) do
    {collected, rest} = Enum.split_while(chars, &is_digit/1)
    lexeme = Enum.join(collected)
    {literal, ""} = Integer.parse(lexeme)

    token = Token.new({:literal, literal}, lexeme, pos)
    lex(rest, [token | tokens], increment(pos, collected))
  end

  def read_string([_quote | rest], tokens, pos) do
    {collected, [_quote | rest]} = Enum.split_while(rest, &(!is_quote(&1)))
    literal = Enum.join(collected)
    token = Token.new({:literal, literal}, "'#{literal}'", pos)

    # add 2x `nil` to account for the quotes
    lex(rest, [token | tokens], increment(pos, [nil, nil] ++ collected))
  end

  def read_next_char(_chars = [ch | rest], tokens, pos) do
    token =
      case ch do
        "(" -> Token.new(:opening, ch, pos)
        ")" -> Token.new(:closing, ch, pos)
        "=" -> Token.new(:symbol, ch, pos)
        "-" -> Token.new(:symbol, ch, pos)
        "*" -> Token.new(:symbol, ch, pos)
        "/" -> Token.new(:symbol, ch, pos)
        "^" -> Token.new(:symbol, ch, pos)
        "%" -> Token.new(:symbol, ch, pos)
        "&" -> Token.new(:symbol, ch, pos)
        "@" -> Token.new(:symbol, ch, pos)
        "#" -> Token.new(:symbol, ch, pos)
        "!" -> Token.new(:symbol, ch, pos)
        "~" -> Token.new(:symbol, ch, pos)
        "<" -> Token.new(:symbol, ch, pos)
        ">" -> Token.new(:symbol, ch, pos)
        _ -> raise LexingError, lexeme: ch, position: pos
      end

    lex(rest, [token | tokens], increment(pos, ch))
  end

  defp is_whitespace(ch) do
    ch in ["\n", "\t", "\v", "\r", " "]
  end

  defp is_letter(ch) do
    is_lower(ch) or is_upper(ch) or is_special(ch)
  end

  defp is_lower(ch), do: "a" <= ch && ch <= "z"
  defp is_upper(ch), do: "A" <= ch && ch <= "Z"
  defp is_special(ch), do: ch in @special

  defp is_digit(ch) do
    "0" <= ch && ch <= "9"
  end

  def is_quote(ch) do
    ch == ~s/"/
  end
end
