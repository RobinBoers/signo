defmodule Signo.Token do
  @moduledoc """
  A token.
  """
  use TypedStruct

  alias Signo.Position

  typedstruct enforce: true do
    @typedoc """
    A token.

    Has the following fields:

    - `type`: the type of token, see `t:type/0`.
    - `lexeme`: the string as found in the source code.
    """

    field :type, type() | :error
    field :lexeme, String.t()
    field :position, Position.t()
  end

  @type type ::
          :eof
          | :opening
          | :closing
          | :symbol
          | {:literal, literal()}
          | {:keyword, kw()}

  @typedoc """
  A valid keyword.
  """
  @type kw :: :if | :let | :def | :lambda

  @typedoc """
  The value of the literal as an elixir `t:term/0`.
  Example: `30_000`
  """
  @type literal :: binary() | integer() | float() | boolean()

  @spec new(type(), String.t(), Position.t()) :: t()
  def new(type, lexeme, pos) do
    %__MODULE__{
      type: type,
      lexeme: lexeme,
      position: pos
    }
  end
end
