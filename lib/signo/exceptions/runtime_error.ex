defmodule Signo.RuntimeError do
  @moduledoc """
  Raised when the compiler encounters *some* sort of error
  while evaluating the AST.
  """
  defexception [:message]

  @impl true
  def exception(message: message, position: pos) do
    %__MODULE__{message: "#{message} at #{pos}"}
  end
end
