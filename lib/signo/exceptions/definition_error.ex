defmodule Signo.DefinitionError do
  @moduledoc """
  Raised when assigning directly to a namespace.
  """
  defexception [:message, :reference]

  @impl true
  def exception(reference: ref, position: pos) do
    %__MODULE__{
      message: "'#{ref}' is an illegal reference at #{pos}",
      reference: ref
    }
  end
end
