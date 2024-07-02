# credo:disable-for-this-file Credo.Check.Consistency.ParameterPatternMatching
defmodule Signo.Interpreter do
  @moduledoc false

  alias Signo.AST
  alias Signo.Env
  alias Signo.StdLib

  alias Signo.AST.{Procedure, Block, Nil, Literal, Symbol, If, Let, Lambda, Builtin}

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

  defmodule ArgumentError do
    @moduledoc """
    Raised when a function is called with the wrong amount of arguments.
    """
    defexception [:message]

    @impl true
    def exception(arity: arity, given: given, position: pos) do
      %__MODULE__{
        message: "function takes #{arity}, but #{length(given)} were given at #{pos}"
      }
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
  defp evaluate([node], env), do: eval(node, env)

  defp evaluate([node | rest], env) do
    {_, env} = eval(node, env)
    evaluate(rest, env)
  end

  defp eval(%Let{reference: ref, value: value}, env) do
    {value, env} = eval(value, env)
    {value, Env.assign(env, ref, value)}
  end

  defp eval(%Symbol{reference: ref, pos: pos}, env) do
    {Env.lookup!(env, ref, pos), env}
  end

  defp eval(%Lambda{closure: nil} = lambda, env) do
    {%Lambda{lambda | closure: Env.new(env)}, env}
  end

  defp eval(%node{} = literal, env)
       when node in [Nil, Literal, Lambda, Builtin] do
    {literal, env}
  end

  defp eval(%If{} = branch, env) do
    scoped(&eval_if/2, branch, env)
  end

  defp eval(%Block{expressions: expressions}, env) do
    {expressions, _} = eval_list(expressions, env)
    {hd(expressions), env}
  end

  defp eval(%Procedure{expressions: expressions} = proc, env) do
    {expressions, env} = eval_list(expressions, env)
    scoped(&eval_prodecure/2, {proc, expressions}, env)
  end

  defp eval_if(%If{} = branch, env) do
    {value, env} = eval(branch.condition, env)

    if truthy?(value),
      do: eval(branch.then, env),
      else: eval(branch.else, env)
  end

  defp eval_prodecure({%Procedure{} = proc, expressions}, env) do
    case Enum.reverse(expressions) do
      [%Lambda{arguments: args} | params] when length(params) != length(args) ->
        raise ArgumentError, arity: length(args), given: params, position: proc.pos

      [%Lambda{arguments: args, body: body, closure: env} | params] ->
        eval(body, Env.new(env, args |> Enum.map(& &1.reference) |> Enum.zip(params)))

      [%Builtin{arity: arity} | params] when length(params) != arity ->
        raise ArgumentError, defined: arity, given: params, position: proc.pos

      [%Builtin{definition: definition} | params] ->
        {apply(StdLib, definition, params) |> Literal.new(), env}

      [node | _] ->
        raise RuntimeError, message: "#{node} is not a function", position: proc.pos
    end
  rescue
    FunctionClauseError ->
      # credo:disable-for-next-line
      raise TypeError, position: proc.pos
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
      %Literal{value: true} -> true
      %Literal{value: false} -> false
      %Nil{} -> false
      _ -> true
    end
  end
end
