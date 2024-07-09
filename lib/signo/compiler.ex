defmodule Signo.Compiler do
  @moduledoc false

  alias Signo.AST
  alias Signo.AST.List
  alias Signo.AST.Number

  @param_registers ["RDI", "RSI", "RDX"]

  @builtins %{
    "+" => "plus"
  }

  @syscalls %{
    "exit" => "0x2000001"
  }

  @spec compile!(AST.t()) :: :ok
  def compile!(%AST{expressions: expressions}) do
    emit 0, "global _start"
    emit 0, "section .text"
    emit 0, ""
    emit 0, "plus:"
    emit "ADD RDI, RSI"
    emit "MOV RAX, RDI"
    emit "RET"
    emit 0, ""
    emit 0, "_main:"
    compile(expressions)
    emit "RET"
    emit 0, ""
    emit 0, "_start:"
    emit "call _main"
    emit "MOV RDI, RAX"
    emit "MOV RAX, #{@syscalls["exit"]}"
    emit "SYSCALL"
  end

  defp compile([]), do: :ok

  defp compile([expression | rest]) do
    compile_expression(expression)
    compile(rest)
  end

  defp compile_expression(expression, dest \\ nil)

  defp compile_expression(%List{expressions: [head | args]}, dest) do
    args = Enum.zip(@param_registers, args)

    for {register, arg} <- args do
      emit "PUSH #{register}"
      compile_expression(arg, register)
    end

    fun = head.reference
    emit("CALL #{@builtins[fun] || fun}")

    for {register, _arg} <- args do
      emit "POP #{register}"
    end

    if dest do
      emit "MOV #{dest}, RAX"
    end

    # Nice formatting :)
    emit 0, ""
  end

  defp compile_expression(%Number{value: value}, dest) do
    emit "MOV #{dest}, #{value}"
  end

  defp emit(depth \\ 1, code) do
    indent = String.duplicate("  ", depth)
    IO.puts(indent <> code)
  end
end
