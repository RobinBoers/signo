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

    @spec new([AST.expression()]) :: t()
    def new(expressions) do
      %__MODULE__{expressions: expressions}
    end
  end

  defmodule Literal do
    @moduledoc """
    A literal value, as an elixir `t:term/0`.
    """

    @type value :: binary() | integer() | float() | boolean()

    typedstruct enforce: true do
      field :value, value()
    end

    @spec new(value()) :: t()
    def new(value) do
      %__MODULE__{value: value}
    end
  end

  defmodule Symbol do
    @moduledoc """
    A reference to variable or function in scope.
    """

    typedstruct enforce: true do
      field :reference, String.t()
    end

    @spec new(String.t()) :: t()
    def new(ref) do
      %__MODULE__{reference: ref}
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

    @spec new(AST.expression(), AST.expression(), AST.expression()) :: t()
    def new(condition, then, otherwise) do
      %__MODULE__{
        condition: condition,
        then: then,
        else: otherwise
      }
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

    @spec new(String.t(), AST.expression()) :: t()
    def new(ref, value) do
      %__MODULE__{
        reference: ref,
        value: value
      }
    end
  end

  defmodule Lambda do
    @moduledoc """
    A declaration of a function in scope.
    """

    typedstruct enforce: true do
      field :arguments, [Symbol.t()]
      field :body, AST.expression()
    end

    @spec new([Symbol.t()], AST.expression()) :: t()
    def new(args, body) do
      %__MODULE__{
        arguments: args,
        body: body
      }
    end
  end
end
