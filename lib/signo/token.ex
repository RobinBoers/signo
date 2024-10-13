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
    - `pos`: the `Signo.Position` where the source string was found.
    """

    field :type, type() | :error
    field :lexeme, binary()
    field :pos, Position.t()
  end

  @type type ::
          :eof
          | :opening
          | :closing
          | :quote
          | :symbol
          | {:literal, literal()}

  @typedoc """
  The value of the literal as an elixir `t:term/0`.
  Example: `30_000`.
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
