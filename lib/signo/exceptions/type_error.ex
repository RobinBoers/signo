defmodule Signo.TypeError do
  @moduledoc """
  Raised when the compiler encounters mismatched types
  for a function.
  """
  defexception [:message]

  @impl true
  def exception(position: pos) do
    %__MODULE__{message: "mismatched types or mismatched number of arguments at #{pos}"}
  end
end
