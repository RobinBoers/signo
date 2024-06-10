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

  defmodule TokenizeError do
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
      - `lexeme`: the string as found in the source code. Forexample: `"3.0e4"`.
      """

      field :type, type() | :error
      field :lexeme, String.t()
      field :row, non_neg_integer(), default: 0
      field :col, non_neg_integer(), default: 0
    end

    @type type ::
      :opening
      | :closing
      | :symbol
      | {:literal, literal()}

      # I haven't defined all possible operators and keywords here, because then
      # they'd be duplicated, as they're down here too.
      | {:keyword, atom()}
      | {:operator, atom()}

    @keywords %{
      :let => "let",
      :def => "def",
      :if => "if"
    }

    @operators %{
      equals: "==",
      not_equals: "!==",
      lt: "<",
      gt: ">",
      lte: "<=",
      gte: ">=",
      not: "not",
      and: "and",
      or: "or",
      nor: "nor",
      xor: "xor"
    }

    @overloadables ["+", "-", "*", "/", "^", "%", "@", "&", "#"]

    @typedoc """
    The value of the literal as an elixir `t:term/0`.
    Example: `30_000`
    """
    @type literal :: integer() | float() | String.t()

    @spec new(String.t()) :: t()
    def new(lexeme) do
      if type = type(lexeme) do
        %__MODULE__{
          type: type,
          lexeme: lexeme
        }
      else
        raise TokenizeError, %__MODULE__{
          type: :error,
          lexeme: lexeme
        }
      end
    end

    defp type(lexeme) do
      case lexeme do
        "(" -> :opening
        ")" -> :closing
        lexeme ->
          keyword(lexeme) || operator(lexeme) || literal(lexeme) || symbol(lexeme)
      end
    end

    defp keyword(lexeme) do
      if kw = reverse_lookup(@keywords, lexeme), do: {:keyword, kw}
    end

    defp operator(lexeme) do
      if op = reverse_lookup(@operators, lexeme), do: {:operator, op}
    end

    defp literal(lexeme) do
      integer(lexeme) || float(lexeme) || string(lexeme) || boolean(lexeme)
    end

    defp integer(lexeme) do
      if Regex.match?(~r/^[[:digit:]]+$/, lexeme) do
        {:literal, String.to_integer(lexeme)}
      end
    end

    defp float(lexeme) do
      if Regex.match?(~r/^[[:digit:]]+\.[[:digit:]]+$/, lexeme) do
        {:literal, String.to_float(lexeme)}
      end
    end

    defp string(lexeme) do
      case Regex.run(~r/^"([^"]*)"$/, lexeme) do
        [^lexeme, contents] -> {:literal, contents}
        _ -> nil
      end
    end

    defp boolean(lexeme) do
      if lexeme in ["true", "false"] do
        {:literal, String.to_existing_atom(lexeme)}
      end
    end

    defp symbol(lexeme) do
      if lexeme in @overloadables or
        Regex.match?(~r/^[[:alnum:]_]+$/i, lexeme) do
        :symbol
      end
    end
  end

  def main(filename \\ "main.sg") do
    filename
    |> File.read!()
    |> tokenize!()
    |> dbg()
  end

  @doc """
  Converts a string containing valid Signo source code into
  a list of `Signo.Token`s.

  Raises `Signo.TokenizeError` when encountering unknown characters.

  Multiple lines are supported.
  """
  @spec tokenize!(String.t()) :: [Token.t()]
  def tokenize!(source) do
    source
    |> pad("(")
    |> pad(")")
    |> String.split()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Token.new/1)
  end

  defp pad(haystack, needle) do
    String.replace(haystack, needle, " #{needle} ")
  end
end
