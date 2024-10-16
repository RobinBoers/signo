defmodule Signo.Interpreter do
  @moduledoc false

  import Signo.AST, only: [is_value: 1]

  alias Signo.AST
  alias Signo.AST.Atom
  alias Signo.AST.Builtin
  alias Signo.AST.Construct
  alias Signo.AST.Lambda
  alias Signo.AST.List
  alias Signo.AST.Nil
  alias Signo.AST.Quoted
  alias Signo.AST.Symbol
  alias Signo.Env
  alias Signo.RuntimeError
  alias Signo.SpecialForms
  alias Signo.StdLib
  alias Signo.TypeError

  @spec evaluate!(AST.t()) :: {AST.value(), Env.t()}
  def evaluate!(ast) do
    evaluate(ast.expressions, Env.new(StdLib.kernel()))
  end

  @spec evaluate!(AST.t(), Env.t()) :: {AST.value(), Env.t()}
  def evaluate!(ast, env) do
    evaluate(ast.expressions, env)
  end

  @spec evaluate([AST.expression()], Env.t()) :: {AST.value(), Env.t()}
  defp evaluate([], env), do: {Nil.new(), env}
  defp evaluate([node], env), do: eval(node, env)

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

  def eval(%List{expressions: [head | params], pos: pos}, env) do
    {head, env} = eval(head, env)

    case head do
      %Lambda{} = lambda ->
        {params, env} = eval_list(params, env)
        {eval_call(lambda, Enum.reverse(params)), env}

      %Builtin{definition: definition} ->
        {params, env} = eval_list(params, env)
        {apply(StdLib, definition, [Enum.reverse(params)]), env}

      %Construct{definition: definition} ->
        apply(SpecialForms, definition, [params, env, pos])

      node ->
        raise RuntimeError, message: "#{node} is not callable", position: pos
    end
  rescue
    FunctionClauseError -> raise TypeError, position: pos
  end

  def eval_list(expressions, env) do
    Enum.reduce(expressions, {[], env}, fn expression, {acc, env} ->
      {value, env} = eval(expression, env)
      {[value | acc], env}
    end)
  end

  def eval_call(callable, params) do
    %{self: ref, arguments: args, body: body, closure: env} = callable
    env = if ref, do: Env.assign(env, ref, callable), else: env
    bindings = args |> Enum.map(& &1.reference) |> Enum.zip(params)
    {value, _} = eval(body, Env.new(env, bindings))
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
