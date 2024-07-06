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
          List.t()
          | Quoted.t()
          | Nil.t()
          | Number.t()
          | Atom.t()
          | String.t()
          | Symbol.t()
          | Lambda.t()
          | Builtin.t()
          | Macro.t()

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
          Nil.t()
          | Number.t()
          | Atom.t()
          | String.t()
          | Lambda.t()
          | Builtin.t()
          | Macro.t()

  defguard is_value(node)
    when is_struct(node, AST.Nil)
    or is_struct(node, Number)
    or is_struct(node, Atom)
    or is_struct(node, String)
    or is_struct(node, Lambda)
    or is_struct(node, Builtin)
    or is_struct(node, Macro)

  typedstruct enforce: true do
    field :expressions, [expression()]
  end

  defmodule List do
    @moduledoc """
    A data structure holding a list of expressions.

    Internally implemented as an Elixir list, which is in turn
    implemented a linked list.
    """

    typedstruct enforce: true do
      field :expressions, [AST.expression()]
      field :pos, Position.t()
    end

    @spec new([AST.expression()], Position.t()) :: t()
    def new(expressions, pos) do
      %__MODULE__{expressions: expressions, pos: pos}
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{expressions: expressions}) do
        "<list>(#{Enum.join(expressions, " ")})"
      end
    end
  end

  defmodule Quoted do
    @moduledoc """
    An expression that is passed as-is, without being evaluated first.
    """

    typedstruct enforce: true do
      field :expression, AST.expression()
    end

    @spec new(AST.expression()) :: t()
    def new(expression) do
      %__MODULE__{expression: expression}
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{expression: expression}) do
        Kernel.to_string(expression)
      end
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
      def to_string(%@for{value: number}) do
        Kernel.to_string(number)
      end
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

  defmodule Lambda do
    @moduledoc """
    A declaration of a function with enclosed environment.
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

  defmodule Macro do
    @moduledoc """
    A reference to a macro in the `Signo.SpecialForms`.
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
      def to_string(%@for{definition: definition}), do: "<macro>(#{definition})"
    end
  end
end
