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
    field :lexeme, binary()
    field :pos, Position.t()
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
  @type kw :: :if | :let | :def | :lambda | :do | :list

  @typedoc """
  The value of the literal as an elixir `t:term/0`.
  Example: `30_000`
  """
  @type literal :: binary() | number() | atom()

  @spec new(type(), binary(), Position.t()) :: t()
  def new(type, lexeme, pos) do
    %__MODULE__{
      type: type,
      lexeme: lexeme,
      pos: pos
    }
  end
end
