defmodule Signo.StdLibTest do
  use ExUnit.Case, async: true

  import Signo.DocTest

  doctest_sig Signo.StdLib
end
