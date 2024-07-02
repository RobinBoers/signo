defmodule Signo.Env do
  @moduledoc """
  Struct holding all variable and function definitions in
  a certain scope.

  Scopes can be nested. Whenever a variable is being looked up,
  the lookup will walk the scope-chain up until it finds a definition.
  """
  use TypedStruct

  alias Signo.AST
  alias Signo.Position
  alias Signo.Interpreter.ReferenceError

  @type scope :: %{AST.ref() => AST.expression()}
  @type definition :: AST.expression() | :undefined

  typedstruct enforce: true do
    field :parent, t() | nil, default: nil
    field :scope, scope(), default: %{}
  end

  @spec new(t(), [{AST.ref(), AST.expression()}]) :: t()
  def new(parent, definitions \\ []) do
    %__MODULE__{
      parent: parent,
      scope: Map.new(definitions)
    }
  end

  @spec assign(t(), AST.ref(), AST.expression()) :: t()
  def assign(env = %__MODULE__{}, ref, value) do
    %__MODULE__{env | scope: Map.put(env.scope, ref, value)}
  end

  @spec lookup!(nil, AST.ref(), Position.t()) :: no_return()
  def lookup!(nil, ref, pos) do
    raise ReferenceError, reference: ref, position: pos
  end

  @spec lookup!(t(), AST.ref(), Position.t()) :: definition()
  def lookup!(env = %__MODULE__{}, ref, pos) do
    if value = Map.get(env.scope, ref),
      do: value,
      else: lookup!(env.parent, ref, pos)
  end
end
