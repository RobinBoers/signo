defmodule Signo.AST do
  @moduledoc """
  AST definitions for the Signo Programming Language.
  """
  use TypedStruct

  alias __MODULE__
  alias Signo.Position
  alias Signo.Env

  @typedoc """
  An expression is a building block for the AST
  that evaluates down to an `t:value/0`.
  """
  @type expression ::
          __MODULE__.Procedure.t()
          | __MODULE__.Block.t()
          | __MODULE__.Nil.t()
          | __MODULE__.Number.t()
          | __MODULE__.Atom.t()
          | __MODULE__.String.t()
          | __MODULE__.List.t()
          | __MODULE__.Symbol.t()
          | __MODULE__.If.t()
          | __MODULE__.Let.t()
          | __MODULE__.Lambda.t()
          | __MODULE__.Builtin.t()

  @typedoc """
  A reference is a key by which a `t:value/0` can
  be lookup up in the `Signo.Env`.
  """
  @type ref :: binary()

  @typedoc """
  A value is an expression that cannot be further
  simplied by evaluating it.
  """
  @type value ::
          __MODULE__.Nil.t()
          | __MODULE__.Number.t()
          | __MODULE__.Atom.t()
          | __MODULE__.String.t()
          | __MODULE__.List.t()
          | __MODULE__.Lambda.t()
          | __MODULE__.Builtin.t()

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

    defimpl Elixir.String.Chars do
      def to_string(%@for{}), do: "()"
    end
  end

  defmodule Number do
    @moduledoc """
    A number value.
    """

    typedstruct enforuce: true do
      field :value, number()
    end

    @spec new(number()) :: t()
    def new(number) do
      %__MODULE__{value: number}
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{value: number}), do: "#{number}"
    end
  end

  defmodule Atom do
    @moduledoc """
    An atom value.
    """

    typedstruct enforuce: true do
      field :value, atom()
    end

    @spec new(atom()) :: t()
    def new(atom) do
      %__MODULE__{value: atom}
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{value: atom}), do: "##{atom}"
    end
  end

  defmodule String do
    @moduledoc """
    A string value.
    """

    typedstruct enforuce: true do
      field :value, binary()
    end

    @spec new(binary()) :: t()
    def new(string) do
      %__MODULE__{value: string}
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{value: string}), do: string
    end
  end

  defmodule List do
    @moduledoc """
    A data structure holding a list of `t:Signo.AST.value/0`.

    Internally implemented as an Elixir list, which is in turn
    implemented a linked list.
    """

    typedstruct enforuce: true do
      field :expressions, [AST.expression()]
    end

    @spec new([AST.expression()]) :: t()
    def new(expressions) do
      %__MODULE__{expressions: expressions}
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{expressions: expressions}) do
        "<list>(#{Enum.join(expressions, " ")})"
      end
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

    defimpl Elixir.String.Chars do
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

    defimpl Elixir.String.Chars do
      def to_string(%@for{arguments: args}) do
        "<lambda>(#{Enum.map_join(args, " ", & &1.reference)} -> ...)"
      end
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

    defimpl Elixir.String.Chars do
      def to_string(%@for{definition: definition}), do: "<builtin>(#{definition})"
    end
  end
end
