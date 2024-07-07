defmodule Signo.ParseError do
  @moduledoc """
  Raised when the compiler encounters an unexpected token,
  or when a token is missing.
  """
  defexception [:message, :token]

  @impl true
  def exception(message: message, token: token, pos: pos) do
    %__MODULE__{
      message: "#{message} at #{pos}",
      token: token
    }
  end

  @impl true
  def exception(token) do
    %__MODULE__{
      message: "unexpected '#{token.lexeme}' at #{token.pos}",
      token: token
    }
  end
end
