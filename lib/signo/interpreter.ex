# credo:disable-for-this-file Credo.Check.Consistency.ParameterPatternMatching
defmodule Signo.Interpreter do
  @moduledoc false

  alias Signo.AST
  alias Signo.Env
  alias Signo.StdLib
  alias Signo.SpecialForms

  alias Signo.AST.{List, Quoted, Nil, Number, Atom, String, List, Symbol, If, Let, Lambda, Macro, Builtin}

  import Signo.AST, only: [is_value: 1]

  defmodule RuntimeError do
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

  defmodule TypeError do
    @moduledoc """
    Raised when the compiler encounters mismatched types
    for a function.
    """
    defexception [:message]

    @impl true
    def exception(position: pos) do
      %__MODULE__{message: "mismatched types at #{pos}"}
    end
  end

  defmodule ReferenceError do
    @moduledoc """
    Raised when the interpreter tries to access a reference to
    a non-existant or undefined variable or function.
    """
    defexception [:message, :reference]

    @impl true
    def exception(reference: ref, position: pos) do
      %__MODULE__{
        message: "'#{ref}' is undefined at #{pos}",
        reference: ref
      }
    end
  end

  @spec evaluate!(AST.t()) :: {AST.value(), Env.t()}
  def evaluate!(ast) do
    evaluate(ast.expressions, StdLib.kernel() |> Env.new())
  end

  @spec evaluate!(AST.t(), Env.t()) :: {AST.value(), Env.t()}
  def evaluate!(ast, env) do
    evaluate(ast.expressions, env)
  end

  @spec evaluate([AST.expression()], Env.t()) :: {AST.value(), Env.t()}
  defp evaluate([], env), do: {Nil.new(), env}
  defp evaluate([node | rest], env) do
    {_, env} = eval(node, env)
    evaluate(rest, env)
  end

  def eval(%Symbol{reference: ref, pos: pos}, env) do
    {Env.lookup!(env, ref, pos), env}
  end

  def eval(%Quoted{expression: expression}, env) do
    {expression, env}
  end

  def eval(value, env) when is_value(value) do
    {value, env}
  end

  def eval(%List{expressions: [head, params]} = proc, env) do
    case head do
      %Lambda{} = lambda ->
        {params, env} = eval_list(params, env)
        {eval_call(lambda, params), env}

      %Builtin{definition: definition} ->
        {params, env} = eval_list(params, env)
        {apply(StdLib, definition, [params]), env}

      %Macro{definition: definition} ->
        {apply(SpecialForms, definition, [params]), env}        

      [node | _] ->
        raise RuntimeError, message: "#{node} is not a function", position: proc.pos
    end
  end

  defp eval_list(expressions, env) do
    Enum.reduce(expressions, {[], env}, fn expression, {acc, env} ->
      {value, env} = eval(expression, env)
      {[value | acc], env}
    end)
  end

  defp eval_call(callable, params) do
    %{args: args, body: body, closure: closure} = callable
    bindings = args |> Enum.map(& &1.reference) |> Enum.zip(params)
    {value, _} = eval(body, Env.new(closure, bindings))
    value
  end

  def truthy?(object) do
    case object do
      %Atom{value: true} -> true
      %Atom{value: false} -> false
      %Nil{} -> false
      _ -> true
    end
  end
end
