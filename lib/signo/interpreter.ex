defmodule Signo.Interpreter do
  @moduledoc false

  alias Signo.AST
  alias Signo.Env

  alias Signo.AST.{Literal, Symbol, List, If, Let, Lambda}

  defmodule RuntimeError do
    @moduledoc """
    Raised when the compiler encounters *some* sort of error
    while evaluating the AST.
    """
    defexception [:message, :position]

    @impl true
    def exception(message: message, position: pos) do
      %__MODULE__{
        message: "#{message} at #{pos}",
        position: pos
      }
    end
  end

  defmodule TypeError do
    @moduledoc """
    Raised when the compiler encounters mismatched types
    for a function.
    """
    defexception [:message, :position]

    @impl true
    def exception(message: message, position: pos) do
      %__MODULE__{
        message: "#{message} at #{pos}",
        position: pos
      }
    end
  end

  @cached_true %Literal{value: true}
  @cached_false %Literal{value: false}
  @cached_nil %List{expressions: []}

  defguardp is_block(expressions)
            when expressions |> hd() |> is_struct(List)

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

  defp eval(%If{} = branch, env) do
    {value, env} = eval(branch.condition, env)

    if truthy?(value),
      do: eval(branch.then, env),
      else: eval(branch.else, env)
  end

  defp eval(%List{expressions: expressions}, env) do
    {expressions, env} = eval_list(expressions, env)

    if is_block(expressions),
      do: {expressions |> Enum.reverse() |> hd(), env},
      else: eval_call(expressions, env)
  end

  defp eval_list(expressions, env) do
    Enum.reduce(expressions, {[], env}, fn expression, {acc, env} ->
      {value, env} = eval(expression, env)
      {[value | acc], env}
    end)
  end

  defp eval_call([%Lambda{arguments: args} | params], _) when length(args) != length(params) do
    raise RuntimeError,
      message: "function takes #{length(args)}, but #{length(params)} were given"
  end

  defp eval_call([%Lambda{arguments: args, body: body} | params], env) do
    env = Env.populate(env, Enum.zip(args, params))
    eval(body, env)
  end

  defp eval_call([node | _], _) do
    raise RuntimeError,
      message: "#{node} is not a function"
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
