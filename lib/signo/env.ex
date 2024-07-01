defmodule Signo.Env do
  @moduledoc """
  Struct holding all variable and function definitions in
  a certain scope.

  Scopes can be nested. Whenever a variable is being looked up,
  the lookup will walk the scope-chain up until it finds a definition.
  """
  use TypedStruct

  alias Signo.AST

  defmodule ReferenceError do
    @moduledoc """
    Raised when the interpreter tries to access a reference to
    a non-existant or undefined variable or function.
    """
    defexception [:message, :reference]

    @impl true
    def exception(ref) do
      %__MODULE__{
        message: "'#{ref}' is undefined",
        reference: ref
      }
    end
  end

  @type scope :: %{AST.ref() => AST.expression()}

  typedstruct enforce: true do
    field :parent, t() | nil, default: nil
    field :scope, scope(), default: %{}
  end

  @spec new(t()) :: t()
  def new(parent) do
    %__MODULE__{parent: parent}
  end

  @spec lookup(nil, AST.ref()) :: no_return()
  def lookup(nil, ref) do
    raise ReferenceError, ref
  end

  @spec lookup(t(), AST.ref()) :: AST.expression()
  def lookup(env, ref) do
    Map.get(env.scope, ref, lookup(env.parent, ref))
  end
end
