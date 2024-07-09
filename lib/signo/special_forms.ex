defmodule Signo.SpecialForms do
  @moduledoc """
  Macro definitions for core language features.
  """

  import Signo.Interpreter, only: [eval: 2, eval_list: 2, truthy?: 1]

  alias Signo.AST.Lambda
  alias Signo.AST.List
  alias Signo.AST.Nil
  alias Signo.AST.String
  alias Signo.AST.Symbol
  alias Signo.Env
  alias Signo.TypeError

  @doc """
  Assigns a symbol to a value for current scope.

      sig> (let x 10)
      10
      sig> (* 2 x)
      20

  """
  def let([%Symbol{reference: ref}, initializer], env, _) do
    {value, env} = eval(initializer, env)
    {value, Env.assign(env, ref, value)}
  end

  @doc """
  Evaluates a (quoted) expression.

      sig> (eval '(print 10))
      10
      #ok

  """
  def eval([node], env, _) do
    # Unintuatively, we need to evaluate the argument twice. 
    # That's because this is a macro; we're not getting the 
    # evaluated version of the argument, we're getting the 
    # AST node. Meaning,  we have to do the evaluation of 
    # arguments, which usually happens automatically (for
    # functions), manually. After that, we *actually* evaluate 
    # the argument :)

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
  def _if([condition, then], env, pos) do
    _if([condition, then, Nil.new()], env, pos)
  end

  def _if([condition, then, otherwise], env, _) do
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
  def _do(expressions, env, _) do
    {values, _} = eval_list(expressions, env)
    {hd(values), env}
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
  def lambda([%Symbol{} = arg, body], env, pos) do
    lambda([List.new([arg], arg.pos), body], env, pos)
  end

  def lambda([%List{expressions: args, pos: pos}, body], env, _) do
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
  def _def([%Symbol{reference: name} = ref, args, body], env, pos) do
    {lambda, env} = lambda([args, body], env, pos)
    let([ref, %Lambda{lambda | self: name}], env, pos)
  end

  @doc """
  Compiles and executes another file at runtime.

      # example.sg
      (print "hello from example.sg!")

      sig> (include "example.sg")
      hello from example.sg!
      #ok

  """
  def include([%String{value: path}], env, pos) do
    base = if pos.path != :nofile, 
      do: Path.dirname(pos.path), else: ""

    Signo.eval_file!(Path.join(base, path), env)
  end
end
