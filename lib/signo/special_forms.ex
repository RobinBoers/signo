defmodule Signo.SpecialForms do
  @moduledoc """
  Macro definitions for core language features.
  """

  alias Signo.AST.Symbol

  import Signo.Interpreter, only: [eval: 2, truthy?: 1]

  @doc """
  Assigns a symbol to a value for current scope.
  """
  def let([%Symbol{reference: ref}, initializer], env) do
    {value, env} = eval(initializer, env)
    {value, Env.assign(env, ref, value)}
  end

  @doc """
  Evaluates a (quoted) expression.
  """
  def _eval([node], env) do
    eval(node, env)
  end

  @doc """
  An execution branch based a on the `condition`. If truthy,
  `then` gets evaluated. If falsy, `otherwise` gets evaluated.
  
  If `otherwise` is not passed, and `condition` evaluated to a
  falsy value, `()` gets returned.
  """
  def _if([condition, then, otherwise], env) do
    {value, scope} = eval(condition, env)
    {value, _} = if truthy?(value), 
      do: eval(then, scope), 
      else: eval(otherwise, scope)

    {value, env}
  end

  @doc """
  A scoped list of expressions that evaluates to 
  the value of the last expression.
  """
  def _do(args, env) do
    {value, env} = eval(condition, env)

    if truthy?(value),
      do: eval(then, env),
      else: eval(otherwise, env)
  end

  @doc """
  Conditional branching.
  """
  def lambda([_arguments, _body], env) do
    {"TODO", env}
  end

  defp scoped(parser, term, env) do
    {value, _} = parser.(term, Env.new(env))
    {value, env}
  end
end