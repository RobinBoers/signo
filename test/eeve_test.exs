defmodule EeveTest do
  use ExUnit.Case
  doctest Eeve

  test "greets the world" do
    assert Eeve.hello() == :world
  end
end
