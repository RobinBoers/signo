defmodule Signo.Lexer do
  @moduledoc false

  alias Signo.Location
  alias Signo.Token

  import Signo.Location, only: [increment: 2]

  defmodule LexingError do
    @moduledoc """
    Raised when the compiler finds an unexpected lexeme while
    tokenizing the source code.
    """
    defexception [:message, :token]

    @impl true
    def exception(token) do
      %__MODULE__{
        message: "unexpected #{token.lexeme}",
        token: token
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

  @spec lex([String.grapheme()], [Token.t()], Location.t()) :: [Token.t()]
  defp lex(chars, tokens \\ [], loc \\ %Location{})

  defp lex(_chars = [], tokens, loc) do
    Enum.reverse([Token.new(:eof, loc) | tokens])
  end

  defp lex(chars = [ch | rest], tokens, loc) do
    cond do
      is_whitespace(ch) -> lex(rest, tokens, loc)
      is_letter(ch) -> read_identifier(chars, tokens, loc)
      is_digit(ch) -> read_number(chars, tokens, loc)
      is_quote(ch) -> read_string(chars, tokens, loc)
      true -> read_next_char(chars, tokens, loc)
    end
  end

  defp read_identifier(chars, tokens) do
    {collected, rest} = Enum.split_while(chars, &is_letter/1)
    lexeme = Enum.join(collected)
    type = lookup_keyword(lexeme)

    token = Token.new(type, lexeme, loc)
    tokenize(rest, [token | tokens], increment(loc, collected))
  end

  defp lookup_keyword(lexeme) do
    if lexeme in @keywords do
      {:keyword, String.to_existing_atom(lexeme)}
    else
      :symbol
    end
  end

  defp read_number(chars, tokens) do
    {collected, rest} = Enum.split_while(chars, &is_digit/1)
    lexeme = Enum.join(collected)
    {literal, ""} = Integer.parse(lexeme)

    token = Token.new({:literal, literal}, lexeme, loc)
    tokenize(rest, [token | tokens], increment(loc, collected))
  end

  def read_string([_quote | rest], tokens) do
    {collected, [_quote | rest]} = Enum.split_while(rest, &(!is_quote(&1)))
    literal = Enum.join(collected)
    token = Token.new({:literal, literal}, "'#{literal}'", loc)

    # add 2x `nil` to account for the quotes
    tokenize(rest, [token | tokens], increment(loc, [nil, nil] ++ collected))
  end

  def read_next_char(_chars = [ch | rest], tokens, loc) do
    token =
      case ch do
        "(" -> Token.new(:opening, ch, loc)
        ")" -> Token.new(:closing, ch, loc)
        "=" -> Token.new(:symbol, ch, loc)
        "-" -> Token.new(:symbol, ch, loc)
        "*" -> Token.new(:symbol, ch, loc)
        "/" -> Token.new(:symbol, ch, loc)
        "^" -> Token.new(:symbol, ch, loc)
        "%" -> Token.new(:symbol, ch, loc)
        "&" -> Token.new(:symbol, ch, loc)
        "@" -> Token.new(:symbol, ch, loc)
        "#" -> Token.new(:symbol, ch, loc)
        "!" -> Token.new(:symbol, ch, loc)
        "~" -> Token.new(:symbol, ch, loc)
        "<" -> Token.new(:symbol, ch, loc)
        ">" -> Token.new(:symbol, ch, loc)
        _ -> Token.new(:illegal, ch, loc)
      end

    tokenize(rest, [token | tokens], increment(loc, ch))
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
