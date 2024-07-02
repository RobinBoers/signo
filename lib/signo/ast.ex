defmodule Signo.AST do
  @moduledoc """
  AST definitions for the Signo Programming Language.
  """
  use TypedStruct

  alias __MODULE__
  alias Signo.Position
  alias Signo.Env

  @type expression ::
          __MODULE__.Procedure.t()
          | __MODULE__.Block.t()
          | __MODULE__.Nil.t()
          | __MODULE__.Literal.t()
          | __MODULE__.Symbol.t()
          | __MODULE__.If.t()
          | __MODULE__.Let.t()
          | __MODULE__.Lambda.t()
          | __MODULE__.Builtin.t()

  @type ref :: String.t()

  typedstruct enforce: true do
    field :expressions, [expression()]
  end

  defmodule Procedure do
    @moduledoc """
    A list of expressions that evaluates to a procedure call.
    """

    typedstruct enforce: true do
      field :expressions, [AST.expression()]
      field :pos, Position.t()
    end

    @spec new([AST.expression()], Position.t()) :: t()
    def new(expressions, pos) do
      %__MODULE__{expressions: expressions, pos: pos}
    end
  end

  defmodule Block do
    @moduledoc """
    A scoped list of expressions that evaluates to the last expression.
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

    defimpl String.Chars do
      def to_string(%@for{}), do: "()"
    end
  end

  defmodule Literal do
    @moduledoc """
    A literal value, as an elixir `t:term/0`.
    """

    @type value :: binary() | number() | atom()

    @enforce_keys [:value]
    defstruct [:value]

    @type t() :: %__MODULE__{value: value()}
    @type t(type) :: %__MODULE__{value: type}

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
      field :pos, Position.t()
    end

    @spec new(AST.ref(), Position.t()) :: t()
    def new(ref, pos) do
      %__MODULE__{reference: ref, pos: pos}
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
      field :closure, Env.t() | nil, default: nil
    end

    @spec new([Symbol.t()], AST.expression()) :: t()
    def new(args, body) do
      %__MODULE__{
        arguments: args,
        body: body
      }
    end
  end

  defmodule Builtin do
    @moduledoc """
    A reference to a function in the `Signo.StdLib`.
    """

    @type definition :: atom()

    typedstruct enforce: true do
      field :definition, definition()
      field :arity, arity() | :arbitrary
    end

    @spec new(definition(), arity()) :: t()
    def new(definition, arity) do
      %__MODULE__{
        definition: definition,
        arity: arity
      }
    end

    defimpl String.Chars do
      def to_string(%@for{definition: definition}), do: "#{definition}"
    end
  end
end
