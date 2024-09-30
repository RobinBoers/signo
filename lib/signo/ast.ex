defmodule Signo.AST do
  @moduledoc """
  AST definitions for the Signo Programming Language.
  """
  use TypedStruct

  alias __MODULE__
  alias Signo.Env
  alias Signo.Position

  @typedoc """
  An expression is a building block for the AST
  that evaluates down to an `t:value/0`.
  """
  @type expression ::
          AST.List.t()
          | AST.Quoted.t()
          | AST.Nil.t()
          | AST.Number.t()
          | AST.Atom.t()
          | AST.String.t()
          | AST.Symbol.t()
          | AST.Lambda.t()
          | AST.Builtin.t()
          | AST.Macro.t()

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
          AST.Nil.t()
          | AST.Number.t()
          | AST.Atom.t()
          | AST.String.t()
          | callable()

  @typedoc """
  Values to which arguments can be applied,
  aka a head to a procedure.
  """
  @type callable ::
          AST.Lambda.t()
          | AST.Builtin.t()
          | AST.Macro.t()

  defguard is_value(node)
    when is_struct(node, AST.Nil)
    or is_struct(node, AST.Number)
    or is_struct(node, AST.Atom)
    or is_struct(node, AST.String)
    or is_struct(node, AST.Lambda)
    or is_struct(node, AST.Builtin)
    or is_struct(node, AST.Macro)

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
    def new(expressions = [_ | _], pos \\ %Position{}) do
      %__MODULE__{expressions: expressions, pos: pos}
    end

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{expressions: expressions}, opts) do
        expressions =
          expressions
          |> Enum.map(&to_doc(&1, opts))
          |> Enum.intersperse(break(" "))
          |> concat()

        concat(["(", expressions, ")"])
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

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{expression: expression}, opts) do
        concat("'", to_doc(expression, opts))
      end
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

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{}, _opts) do
        concat(empty(), "()")
      end
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{}), do: ""
    end
  end

  defmodule Number do
    @moduledoc """
    A number value.
    """

    typedstruct enforce: true do
      field :value, number()
    end

    @spec new(number()) :: t()
    def new(number) do
      %__MODULE__{value: number}
    end

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{value: number}, opts) do
        to_doc(number, opts)
      end
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

    typedstruct enforce: true do
      field :value, atom()
    end

    @spec new(atom()) :: t()
    def new(atom) do
      %__MODULE__{value: atom}
    end

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{value: atom}, _opts) do
        concat(empty(), "##{atom}")
      end
    end

    defimpl Elixir.String.Chars do
      def to_string(%@for{value: atom}) do
        Kernel.to_string(atom)
      end
    end
  end

  defmodule String do
    @moduledoc """
    A string value.
    """

    typedstruct enforce: true do
      field :value, binary()
    end

    @spec new(binary()) :: t()
    def new(string) do
      %__MODULE__{value: string}
    end

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{value: string}, _opts) do
        concat(["\"", string, "\""])
      end
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

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{reference: ref}, _opts) do
        concat(empty(), ref)
      end
    end
  end

  defmodule Lambda do
    @moduledoc """
    A declaration of a function with enclosed environment.
    """

    typedstruct enforce: true do
      field :self, AST.ref() | nil, default: nil
      field :arguments, [Symbol.t()]
      field :body, AST.expression()
      field :closure, Env.t() | nil
    end

    @spec new([Symbol.t()], AST.expression(), Env.t()) :: t()
    def new(args, body, env) do
      %__MODULE__{
        arguments: args,
        body: body,
        closure: env
      }
    end

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{arguments: args}, _opts) do
        arguments =
          args
          |> Enum.map(& &1.reference)
          |> Enum.intersperse(break(" "))
          |> concat()

        concat(["<lambda>(", arguments, " ", "-> ...)"])
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
    end

    @spec new(definition()) :: t()
    def new(definition) do
      %__MODULE__{definition: definition}
    end

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{definition: definition}, _opts) do
        concat(empty(), "<builtin>(#{definition})")
      end
    end
  end

  defmodule Construct do
    @moduledoc """
    A reference to a macro in the `Signo.SpecialForms`.
    """

    @type definition :: atom()

    typedstruct enforce: true do
      field :definition, definition()
    end

    @spec new(definition()) :: t()
    def new(definition) do
      %__MODULE__{definition: definition}
    end

    defimpl Inspect do
      import Inspect.Algebra
      def inspect(%@for{definition: definition}, _opts) do
        concat(empty(), "<macro>(#{definition})")
      end
    end
  end
end
