defmodule Signo.Lexer do
  @moduledoc false

  alias Signo.Cursor
  alias Signo.Token

  import Signo.Cursor, only: [next: 1]
  import Signo.Map, only: [reverse_lookup: 2]

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

  @whitespace ["\n", "\t", "\v", "\r", " "]
  @overloadables ["+", "-", "*", "/", "^", "%", "@", "&", "#", "!", "~", "<", ">", "<=", ">=", "=", "==", "!="]

  def lex!(source) when is_binary(source) do
    source |> Cursor.new() |> interate(fn char, cur ->
      case char do
        ">" -> case next(cursor) do
          {"=", cur} -> token(cur, ">=", :symbol)
          _ -> token(cur, char, :symbol)
        end
        "<" -> case next(cursor) do
          {"=", cursor} -> token(cur, "<=", :symbol)
          _ -> token(cur, char, :symbol)
        end
        "=" -> case next(cursor) do
          {"=", cur} -> token(cur, "==", :symbol)
          _ -> token(cur, char, :symbol)
        end
        "!" -> case next(cursor) do
          {"=", cur} -> token(cur, "!=", :symbol)
          _ -> token(cur, char, :symbol)
        end

        _ when char in @whitespace -> cur
        _ when char in @overloadables -> token(cur, char, :symbol)

        "(" -> token(cur, char, :opening)
        ")" -> token(cur, char, :closing)
        "'" -> iterate(cursor, fn
          "'", cur -> {:break, token(cursor, lexeme, {:literal, literal})}

        end)
      end

      c, acc when c in @whitespace -> acc
      c, acc when c in @overloadables -> token(acc, c, :symbol)
      "(", acc -> token(acc, "(", :symbol)

      c, acc
      case c do
        _ when c in @whitespace -> :cont
        _ when c in @overloadables -> token(cursor, char, :symbol)
        "(" ->

        "'" -> interate(cursor, fn cursor, char ->
          "'" ->
          :eof -> raise LexingError, token(cursor, :eof, :eof)
          _ -> {:cont, cursor}
        end)
      end
    end)
  end



  defp advance(cursor, char) do
    case char do
      _ when char in @whitespace -> cursor
      _ when char in @overloadables -> token(cursor, char, :symbol)
      "(" -> token(cursor, char, :opening)
      ")" -> token(cursor, char, :closing)

    end
  end

  defp string(cursor, lexeme) do
    {cursor, char} = Cursor.next()
    lexeme = lexeme <> char

    case char do



    end
  end

  def interate(cursor, fun) do
    {cursor, char} = Cursor.next()
    case fun.(cursor, char) do
      %Cursor{} = cursor -> interate(cursor, fun)
      :break -> cursor
    end
  end

  defp token(cursor, lexeme, type) do
    Cursor.append(%Token{
      lexeme: lexeme,
      type: type,
      row: cursor.row,
      col: cursor.col
    })
  end
end
