defmodule Signo.AST do
  @moduledoc """
  AST definitions for the Signo Programming Language.
  """
  use TypedStruct

  @type expression ::
          __MODULE__.Call.t()
          | __MODULE__.Block.t()
          | __MODULE__.Literal.t()
          | __MODULE__.Symbol.t()
          | __MODULE__.If.t()
          | __MODULE__.Let.t()
          | __MODULE__.Lambda.t()

  @type ref :: String.t()

  typedstruct enforce: true do
    field :expressions, [expression()]
  end

  defmodule Call do
    @moduledoc """
    A list of expressions that evaluates to a
    procedure call.
    """

    typedstruct enforce: true do
      field :expressions, [AST.expression()]
    end

    @spec new([AST.expression()]) :: t()
    def new(expressions) do
      %__MODULE__{expressions: expressions}
    end
  end

  defmodule Block do
    @moduledoc """
    A list of expressions that evaluates to the
    value of the last expression.
    """

    typedstruct enforce: true do
      field :expressions, [AST.expression()]
    end

    @spec new([AST.expression()]) :: t()
    def new(expressions) do
      %__MODULE__{expressions: expressions}
    end
  end

  defmodule Nil do
    @moduledoc """
    The `nil` type.
    """

    typedstruct do
    end

    @spec new() :: t()
    def new do
      %__MODULE__{}
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

    defimpl String.Chars do
      def to_string(%@for{value: value}), do: "#{value}"
    end
  end

  defmodule Symbol do
    @moduledoc """
    A reference to variable or function in scope.
    """

    typedstruct enforce: true do
      field :reference, AST.ref()
    end

    @spec new(AST.ref()) :: t()
    def new(ref) do
      %__MODULE__{reference: ref}
    end

    defimpl String.Chars do
      def to_string(%@for{reference: ref}), do: ref
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
      field :reference, AST.ref()
      field :value, AST.expression()
    end

    @spec new(AST.ref(), AST.expression()) :: t()
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
