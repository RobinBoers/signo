defmodule Signo do
  @moduledoc """
  Signo is a Lisp-like language. That means it has two core concepts:

  - Atomics, which can be subdivided into three categories:

    - Literals, such as `100`, `1.0`, `true`, `"hello world"` and `3.0e10`.
    - References to previously defined variables or functions.
    - Operators: `<`, `<=`, `>`, `>=`, `==`, `!==`, `and`, `or`, `nor`, `xor`, `not`.

  - Lists, such as `("hello", 100, "worlds")`.

  As you can see, both of these are expressions. Because, in Signo, everything is an expression. A list can evaluate to another value when it starts with one of the following keywords:

  - `let` assigns a variable.
  - `if` branches, like this: `(if CONDITION THEN ELSE)`.
  - `def` defines a function, like this: `(NAME ARGUMENTS BODY)`.
  """

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

  defmodule Token do
    @moduledoc """
    Struct representing a token.
    """
    use TypedStruct

    import Signo.Map, only: [reverse_lookup: 2]

    typedstruct enforce: true do
      @typedoc """
      A token.

      Has the following fields:

      - `type`: the type of token, see `t:type/0`.
      - `lexeme`: the string as found in the source code.
      """

      field :type, type() | :error
      field :lexeme, String.t()
      field :row, non_neg_integer()
      field :col, non_neg_integer()
    end

    @type type ::
      :opening
      | :closing
      | :symbol
      | {:literal, literal()}
      | {:keyword, :if | :let | :def}

    @typedoc """
    The value of the literal as an elixir `t:term/0`.
    Example: `30_000`
    """
    @type literal :: integer() | float() | boolean()
  end

  def main(filename \\ "main.sg") do
    filename
    |> File.read!()
    |> lex!()
  end

  defmodule Cursor do
    @moduledoc false
    use TypedStruct

    typedstruct enforce: true do
      field :source, [String.grapheme()]
      field :tokens, [Token.t()], default: []
      field :row, non_neg_integer(), default: 0
      field :col, non_neg_integer(), default: 0
    end

    @spec new(String.t()) :: t()
    def new(source) do
      %__MODULE__{
        source: String.graphemes(source),
      }
    end

    defguard is_done(cursor)
      when cursor.source == []

    @spec done?(t()) :: boolean()
    def done?(cursor) do
      is_done(cursor)
    end

    @spec next(t()) :: {String.grapheme(), t()}
    def next(cursor) when is_done(cursor) do
      {cursor, nil}
    end

    def next(%{source: [char | source]} = cursor) do
      {cursor
       |> update_source(source)
       |> increment(char), char}
    end

    defp update_source(cursor, source) do
      %__MODULE__{cursor | source: source}
    end

    defp increment(c, "\n"), do: %__MODULE__{c | row: c.row + 1, col: 0}
    defp increment(c, _char), do: %__MODULE__{c | col: c.col + 1}

    @spec append(t(), Token.t()) :: t()
    def append(cursor, %Token{} = token) do
      %__MODULE__{cursor | tokens: [token | cursor.tokens]}
    end
  end

  defmodule Lexer do
    @moduledoc false

    import Signo.Cursor, only: [is_done: 1]
    import Signo.Map, only: [reverse_lookup: 2]

    @keywords %{
      let: "let",
      def: "def",
      if: "if"
    }

    @whitespace ["\n", "\t", "\v", "\r", " "]
    @overloadables ["+", "-", "*", "/", "^", "%", "@", "&", "#", "!", "~", "<", ">", "<=", ">=", "==", "!=="]

    def lex!(cursor) when is_done(cursor) do
      cursor.tokens
    end

    def lex!(cursor) do
      cursor
      |> advance()
      |> lex!()
    end

    defp advance(cursor) do
      {cursor, c} = Cursor.next(cursor)
      case c do
        _ when c in @whitespace -> cursor
        _ when c in @overloadables -> token(cursor, c, :symbol)
        "(" -> token(cursor, c, :opening)
        ")" -> token(cursor, c, :closing)
        ~s/"/ -> string(cursor)
      end
    end

    defp string(cursor, acc \\ []) do
      case Cursor.next(cursor) do
        {"\"", cursor} -> token(cursor, )
    end

    defp string(cursor) when is_done(cursor) do
      raise LexingError, cursor.
    end

    defp token(cursor, lexeme, type) when is_atom(type) do
      Cursor.append(cursor, %Token{
        type: type,
        lexeme: lexeme,
        row: cursor.row,
        col: cursor.col
      })
    end
  end

  @doc """
  Converts a string containing valid Signo source code into
  a list of `Signo.Token`s.

  Raises `Signo.LexingError` when encountering unknown characters.

  Multiple lines are supported.
  """
  @spec lex!(String.t()) :: [Token.t()]
  def lex!(source) when is_binary(source) do
    source
    |> Cursor.new()
    |> Lexer.lex!()
  end
end
