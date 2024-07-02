defmodule Signo.Interpreter do
  @moduledoc false

  alias Signo.AST
  alias Signo.Env
  alias Signo.StdLib

  alias Signo.AST.{Literal, Symbol, Procedure, Nil, If, Let, Lambda, Builtin}

  defmodule RuntimeError do
    @moduledoc """
    Raised when the compiler encounters *some* sort of error
    while evaluating the AST.
    """
    defexception [:message]
  end

  defmodule ArgumentError do
    @moduledoc """
    Raised when a function is called with the wrong amount of arguments.
    """
    defexception [:message]

    @impl true
    def exception(defined: defined, given: given) do
      %__MODULE__{
        message: "function takes #{length(defined)}, but #{length(given)} were given"
      }
    end
  end

  defmodule TypeError do
    @moduledoc """
    Raised when the compiler encounters mismatched types
    for a function.
    """
    defexception [:message]
  end

  @literals [Literal, Lambda, Nil]

  @cached_true %Literal{value: true}
  @cached_false %Literal{value: false}
  @cached_nil %Nil{}

  @spec evaluate!(AST.t()) :: Env.t()
  def evaluate!(ast) do
    evaluate(ast.expressions, StdLib.kernel())
  end

  @spec evaluate!(AST.t(), Env.t()) :: Env.t()
  def evaluate!(ast, env) do
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

  defp eval(%node{} = literal, env)
      when node in @literals do
    {literal, env}
  end

  defp eval(%If{} = branch, env) do
    scoped(&eval_if/2, branch, env)
  end

  defp eval(%Procedure{} = call, env) do
    scoped(&eval_prodecure/2, call, env)
  end

  defp eval_if(%If{} = branch, env) do
    {value, env} = eval(branch.condition, env)

    if truthy?(value),
      do: eval(branch.then, env),
      else: eval(branch.else, env)
  end

  defp eval_prodecure(%Procedure{expressions: expressions}, env) do
    {expressions, env} = eval_list(expressions, env)

    case Enum.reverse(expressions) do
      [%Lambda{arguments: args} | params] when length(params) != length(args) ->
        raise ArgumentError, defined: args, given: params

      [%Lambda{arguments: args, body: body} | params] ->
        eval(body, Env.new(env, Enum.zip(args, params)))

      [%Builtin{arity: arity} | params] when length(params) != arity ->
        raise ArgumentError, defined: 1..arity, given: params

      [%Builtin{definition: definition} | params] ->
        {apply(StdLib, definition, params), env}

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
