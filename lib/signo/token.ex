defmodule Signo.Token do
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
    :eof
    | :opening
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
