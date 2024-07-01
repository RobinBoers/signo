defmodule Signo.Interpreter do
  @moduledoc false

  alias Signo.AST
  alias Signo.Env

  alias Signo.AST.{Literal, Symbol, Call, Block, Nil, If, Let, Lambda}

  defmodule RuntimeError do
    @moduledoc """
    Raised when the compiler encounters *some* sort of error
    while evaluating the AST.
    """
    defexception [:message]
  end

  defmodule TypeError do
    @moduledoc """
    Raised when the compiler encounters mismatched types
    for a function.
    """
    defexception [:message]
  end

  @cached_true %Literal{value: true}
  @cached_false %Literal{value: false}
  @cached_nil %Nil{}

  @spec evaluate!(AST.t(), Env.t()) :: Env.t()
  def evaluate!(ast, env \\ %Env{}) do
    evaluate(ast.expressions, env)
  end

  @spec evaluate([AST.expression()], Env.t()) :: Env.t()
  defp evaluate([], env), do: env

  defp evaluate([node | rest], env) do
    {_, env} = eval(node, env)
    evaluate(rest, env)
  end

  defp eval(%Let{reference: ref, value: value}, env) do
    {value, env} = eval(value, env)
    {value, Env.assign(env, ref, value)}
  end

  defp eval(%Symbol{reference: ref}, env) do
    {Env.lookup!(env, ref), env}
  end

  defp eval(%Literal{} = literal, env) do
    {literal, env}
  end

  defp eval(%Lambda{} = lambda, env) do
    {lambda, env}
  end

  defp eval(%Nil{} = empty, env) do
    {empty, env}
  end

  defp eval(%Block{expressions: expressions}, env) do
    {expressions, _} = eval_list(expressions, env)
    {hd(expressions), env}
  end

  defp eval(%If{} = branch, env) do
    scoped(&eval_if/2, branch, env)
  end

  defp eval(%Call{} = call, env) do
    scoped(&eval_call/2, call, env)
  end

  defp eval_if(%If{} = branch, env) do
    {value, env} = eval(branch.condition, env)

    if truthy?(value),
      do: eval(branch.then, env),
      else: eval(branch.else, env)
  end

  defp eval_call(%Call{expressions: expressions}, env) do
    {expressions, env} = eval_list(expressions, env)

    case Enum.reverse(expressions) do
      [%Lambda{arguments: args} | params] when length(args) != length(params) ->
        raise RuntimeError, "function takes #{length(args)}, but #{length(params)} were given"

      [%Lambda{arguments: args, body: body} | params] ->
        eval(body, Env.new(env, Enum.zip(args, params)))

      [node | _] ->
        raise RuntimeError, "#{node} is not a function"
    end
  end

  defp eval_list(expressions, env) do
    Enum.reduce(expressions, {[], env}, fn expression, {acc, env} ->
      {value, env} = eval(expression, env)
      {[value | acc], env}
    end)
  end

  defp scoped(parser, term, env) do
    {value, scoped} = parser.(term, Env.new(env))
    {value, scoped.parent}
  end

  def truthy?(object) do
    case object do
      @cached_true -> true
      @cached_false -> false
      @cached_nil -> false
      _ -> true
    end
  end
end
