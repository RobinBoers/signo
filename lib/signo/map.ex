defmodule Signo.Map do
  @moduledoc """
  An extension of the standard library `Map` module, providing
  various utilities to ease working with Maps.
  """

  @doc """
  Reverse of `Map.get/3`. Looks up a key by it's value, the first time its found.
  """
  @spec reverse_lookup(map(), default, Map.value()) :: Map.key() | default
        when default: term()
  def reverse_lookup(map, value, default \\ nil) do
    Enum.find_value(map, default, fn {k, v} ->
      if v == value, do: k
    end)
  end
end
