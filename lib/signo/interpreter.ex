defmodule Signo.Interpreter do
  @moduledoc false

  alias Signo.Env

  defmodule RuntimeError do
    @moduledoc """
    Raised when the compiler encounters *some* sort of error
    while evaluating the AST.
    """

    defexception [:message, :position]

    @impl true
    def exception(message: message, position: pos) do
      %__MODULE__{
        message: "#{message} at #{pos}",
        position: pos
      }
    end
  end

  defmodule TypeError do
    @moduledoc """
    Raised when the compiler encounters mismatched types
    for a function.
    """

    defexception [:message, :position]

    @impl true
    def exception(message: message, position: pos) do
      %__MODULE__{
        message: "#{message} at #{pos}",
        position: pos
      }
    end
  end

  def evaluate!(env \\ %Env{}, ast) do
    evaluate(ast, env)
  end

  defp evaluate(ast, env) do

  end
end
