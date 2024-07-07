defmodule Signo.ReferenceError do
  @moduledoc """
  Raised when the interpreter tries to access a reference to
  a non-existant or undefined variable or function.
  """
  defexception [:message, :reference]

  @impl true
  def exception(reference: ref, position: pos) do
    %__MODULE__{
      message: "'#{ref}' is undefined at #{pos}",
      reference: ref
    }
  end
end
