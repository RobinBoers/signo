defmodule Signo.SpecialFormsTest do
  use ExUnit.Case

  import Signo.DocTest

  setup do
    # `include` and `import` resolve paths against cwd
    cwd = File.cwd!()
    File.cd!("test/fixtures")
    on_exit(fn -> File.cd!(cwd) end)
  end

  doctest_sig Signo.SpecialForms
end
