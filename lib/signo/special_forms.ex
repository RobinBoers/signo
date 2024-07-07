defmodule Signo.SpecialForms do
  @moduledoc """
  Macro definitions for core language features.
  """

  alias Signo.Env
  alias Signo.AST.{List, Nil, Symbol, Lambda}
  alias Signo.TypeError

  import Signo.Interpreter, only: [eval: 2, eval_list: 2, truthy?: 1]

  @doc """
  Assigns a symbol to a value for current scope.

      sig> (let x 10)
      10
      sig> (* 2 x)
      20

  """
  def let([%Symbol{reference: ref}, initializer], env) do
    {value, env} = eval(initializer, env)
    {value, Env.assign(env, ref, value)}
  end

  @doc """
  Evaluates a (quoted) expression.

      sig> (eval '(print 10))
      10
      #ok

  """
  def _eval([node], env) do
    # Unintuatively, we need to evaluate the argument twice. 
    # That's because this is a macro; we're not getting the 
    # evaluated version of the argument, we're getting the 
    # AST node. Meaning,  we have to do the evaluation of 
    # arguments, which happens automatically  for functions, 
    # manually. After that, we *actually* evaluate the argument :)

    {argument, env} = eval(node, env)
    eval(argument, env)
  end

  @doc """
  An execution branch based a on the `condition`.
  
  If truthy, `then` gets evaluated. If falsy, `otherwise` gets 
  evaluated. If `otherwise` is not passed, and `condition` evaluated 
  to a falsy value, `()` gets returned.

      sig> (if (== 2 (+ 1 1)) (print "math works") (print "universe is broken"))
      math works
      #ok

      sig> (if (== 3 (+ 1 1)) (print "universe still broken"))
      ()

  """
  def _if([condition, then], env) do
    _if([condition, then, Nil.new()], env)
  end

  def _if([condition, then, otherwise], env) do
    {value, scope} = eval(condition, env)
    {value, _} = if truthy?(value), 
      do: eval(then, scope), 
      else: eval(otherwise, scope)

    {value, env}
  end

  @doc """
  Evaluates all expression in a nested scope and then
  returns the value of the last expression.

      sig> (do (let x 10)
               (print 10))
      10
      #ok
      sig> (print x)
      [ReferenceError] x is undefined at nofile:2:8

  """
  def _do(expressions, env) do
    {values, _} = eval_list(expressions, env)
    {Elixir.List.last(values), env}
  end

  @doc """
  Creates an (anonymous) callable function.

      sig> (lambda (a b) (+ a b))
      <lambda>(a b -> ...)
      sig> ((lambda (a b) (+ a b)) 1 2)
      3

  If the function takes only a single argument, the
  parentheses around the argument list can be omitted:

      sig> (lambda n (* 2 n))
      <lambda>(n -> ...)

  """
  def lambda([%Symbol{} = arg, body], env) do
    lambda([List.new([arg], arg.pos), body], env)
  end

  def lambda([%List{expressions: args, pos: pos}, body], env) do
    if Enum.all?(args, &is_struct(&1, Symbol)) do
      {Lambda.new(args, body, env), env}
    else
      raise TypeError, position: pos
    end
  end

  @doc """
  Creates a callable function and assigns in in scope.

      sig> (def add (a b) (+ a b))
      <lambda>(a b -> ...)
      sig> (add 1 2)
      3

  This is syntatic sugar for:

      sig> (let add (lambda (a b) (+ a b)))
      <lambda>(a b -> ...)

  """
  def def([ref, args, body], env) do
    {lambda, env} = lambda([args, body], env)
    let([ref, lambda], env)
  end
end