defmodule Signo.AST do
  @moduledoc """
  AST definitions for the Signo Programming Language.
  """
  use TypedStruct

  @type expression :: List.t() | Literal.t() | Symbol.t() | If.t() | Def.t() | Let.t()

  typedstruct enforce: true do
    field :expressions, [expression()]
  end

  defmodule List do
    @moduledoc """
    A list of expressions.
    """
    typedstruct enforce: true do
      field :expressions, [AST.expression()]
    end
  end

  defmodule Literal do
    @moduledoc """
    A literal value, as an elixir `t:term/0`.
    """
    typedstruct enforce: true do
      field :value, binary() | integer() | float() | boolean()
    end
  end

  defmodule Symbol do
    @moduledoc """
    A reference to variable or function in scope.
    """
    typedstruct enforce: true do
      field :reference, String.t()
    end
  end

  defmodule If do
    @moduledoc """
    An execution branch based a on condition.
    """
    typedstruct enforce: true do
      field :condition, AST.expression()
      field :then, AST.expression()
      field :else, AST.expression()
    end
  end

  defmodule Let do
    @moduledoc """
    A declaration of a variable in scope.
    """
    typedstruct enforce: true do
      field :reference, String.t()
      field :value, AST.expression()
    end
  end

  defmodule Def do
    @moduledoc """
    A declaration of a function in scope.
    """
    typedstruct enforce: true do
      field :reference, String.t()
      field :arguments, [Symbol.t()]
      field :body, AST.expression()
    end
  end
end
