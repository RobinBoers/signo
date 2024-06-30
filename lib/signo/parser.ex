defmodule Signo.Parser do
  @moduledoc false

  defmodule ParseError do
    @moduledoc """
    Raised when the compiler encounters an unexpected token.
    """
    defexception [:message, :token]

    @impl true
    def exception(token) do
      %__MODULE__{
        message: "unexpected #{token.lexeme} at #{token.position}",
        token: token
      }
    end
  end

  def parse!(tokens) do
    dbg(tokens)
    :ok
  end
end
