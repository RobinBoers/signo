defmodule Signo.StdLib do
  @moduledoc """
  Standard Library for the Signo Programming Language.

  > #### A note on function names {: .neutral}
  >
  > Due to requirements for Elixir function names and conflicts with
  > existing Elixir keywords and/or operators, the function names in
  > this module are often different than the function names in Signo.
  >
  > All functions have a small example along them, which contains
  > the Signo names.
  """

  alias Signo.Env
  alias Signo.AST
  alias Signo.AST.{Literal, Builtin}

  import Signo.Interpreter, only: [truthy?: 1]

  @doc false
  @spec kernel() :: Env.t()
  def kernel do
    %Env{
      scope: %{
        "print" =>   Builtin.new(:print, 1),
        "not" =>     Builtin.new(:neg, 1),
        "and" =>     Builtin.new(:and, 2),
        "or" =>      Builtin.new(:either, 2),
        "nor" =>     Builtin.new(:neither, 2),
        "xor" =>     Builtin.new(:xor, 2),
        "==" =>      Builtin.new(:eq, 2),
        "!=" =>      Builtin.new(:not_eq, 2),
        ">" =>       Builtin.new(:gt, 2),
        ">=" =>      Builtin.new(:gte, 2),
        "<" =>       Builtin.new(:lt, 2),
        "<=" =>      Builtin.new(:lte, 2),
        "+" =>       Builtin.new(:add, 2),
        "-" =>       Builtin.new(:sub, 2),
        "*" =>       Builtin.new(:mult, 2),
        "/" =>       Builtin.new(:div, 2),
        "^" =>       Builtin.new(:pow, 2),
        "sqrt" =>    Builtin.new(:sqrt, 1),
        "abs" =>     Builtin.new(:abs, 1),
        "pi" =>      Builtin.new(:pi, 0),
        "tau" =>     Builtin.new(:tau, 0),
        "sin" =>     Builtin.new(:sin, 1),
        "cos" =>     Builtin.new(:cos, 1),
        "tan" =>     Builtin.new(:tan, 1),
        "asin" =>    Builtin.new(:asin, 1),
        "acos" =>    Builtin.new(:acos, 1),
        "atan" =>    Builtin.new(:atan, 1),
        "ln" =>      Builtin.new(:ln, 1),
        "log" =>     Builtin.new(:log, 2),
        "logn" =>    Builtin.new(:logn, 2),
      }
    }
  end

  defguardp both_literals(a, b)
    when is_struct(a, Literal)
    and is_struct(b, Literal)

  defguardp both_numbers(a, b)
    when both_literals(a, b)
    and is_number(a.value)
    and is_number(b.value)

  @doc """
  Prints the given argument to stdout, and returns `#ok`.

      sig> (print 10)
      10
      #ok
      sig>

  """
  @spec print(AST.expression()) :: Literal.value()
  defdelegate print(item), to: IO, as: :puts

  @doc """
  Boolean `not` operator.

  Receives any value (not limited to booleans) and returns `#true` for falsy values,
  and `#false` for truthy ones.

      sig> (not 10)
      #false
      sig> (not ())
      #true

  """
  @spec neg(AST.expression()) :: Literal.value()
  def neg(literal) do
    not truthy?(literal)
  end

  @doc """
  Boolean `and` operator.

  Receives two values (not limited to booleans), and returns `#true` if both
  are truthy. Does NOT short-circuit!

      sig> (and 10 #true)
      #true
      sig> (and #false ())
      #false

  """
  @spec both(AST.expression(), AST.expression()) :: Literal.value()
  def both(a, b) do
    truthy?(a) and truthy?(b)
  end

  @doc """
  Boolean `or` operator.

  Receives two values (not limited to booleans), and returns `#true` if
  one of them is truthy. Does NOT short-circuit!

      sig> (or () #true)
      #true
      sig> (and #false ())
      #false

  """
  @spec either(AST.expression(), AST.expression()) :: Literal.value()
  def either(a, b) do
    truthy?(a) or truthy?(b)
  end

  @doc """
  Boolean `nand` operator.

  Receives two values (not limited to booleans), and returns `#true` if
  both are falsy. Does NOT short-circuit!

      sig> (nor () #true)
      #false
      sig> (nor #false ())
      #true

  """
  @spec neither(AST.expression(), AST.expression()) :: Literal.value()
  def neither(a, b) do
    not (truthy?(a) and truthy?(b))
  end

  @doc """
  Boolean `xor` operator.

  Receives two values (not limited to booleans), and returns `#true` if
  one of them is truthy, but returns `#false` if both are truthy.

      sig> (xor () #true)
      #true
      sig> (xor #false ())
      #false
      sig> (xor #true 10)
      #false

  """
  @spec xor(AST.expression(), AST.expression()) :: Literal.value()
  def xor(a, b) do
    (truthy?(a) and not truthy?(b)) or (truthy?(b) and not truthy?(a))
  end

  @doc """
  Equal to operator.

  Returns `#true` if the two terms are equal.

      sig> (== "same" "same")
      #true
      sig> (== 1 1.0)
      #true
      sig> (== "not" "same")
      #false

  """
  @spec eq(Literal.t(number), Literal.t(number)) :: Literal.value()
  def eq(a, b) when both_literals(a, b) do
    # TODO(robin): make this work for lambdas and builtins too.
    a.value == b.value
  end

  @doc """
  Not equal to operator.

  Returns `#true` if the two terms are not equal.

      sig> (!= "same" "same")
      #false
      sig> (!= 1 1.0)
      #false
      sig> (!= "not" "same")
      #true

  """
  @spec not_eq(Literal.t(), Literal.t()) :: Literal.value()
  def not_eq(a, b) when both_literals(a, b) do
    # TODO(robin): make this work for lambdas and builtins too.
    a.value != b.value
  end

  @doc """
  Greater-than operator.

  Returns `#true` if `a` is greater than `b`.

      sig> (> 3 3)
      #false

  """
  @spec gt(Literal.t(), Literal.t()) :: Literal.value()
  def gt(a, b) when both_numbers(a, b) do
    a.value > b.value
  end

  @doc """
  Greater-than or equal to operator.

  Returns `#true` if `a` is greater than or equal to `b`.

      sig> (>= 3 3)
      #true

  """
  @spec gte(Literal.t(), Literal.t()) :: Literal.value()
  def gte(a, b) when both_numbers(a, b) do
    a.value >= b.value
  end

  @doc """
  Less-than operator.

  Returns `#true` if `a` is less than `b`.

      sig> (< 3 3)
      #false

  """
  @spec lt(Literal.t(), Literal.t()) :: Literal.value()
  def lt(a, b) when both_numbers(a, b) do
    a.value < b.value
  end

  @doc """
  Less-than or equal to operator.

  Returns `#true` if `a` is less than or equal to `b`.

      sig> (<= 3 3)
      #true

  """
  @spec lte(Literal.t(), Literal.t()) :: Literal.value()
  def lte(a, b) when both_numbers(a, b) do
    a.value <= b.value
  end

  @doc """
  Adds two numbers.

      sig> (+ 2 3)
      5

  """
  @spec add(Literal.t(), Literal.t()) :: Literal.value()
  def add(a, b) when both_numbers(a, b) do
    a.value + b.value
  end

  @doc """
  Substracts two numbers.

      sig> (- 3 2)
      1

  """
  @spec sub(Literal.t(), Literal.t()) :: Literal.value()
  def sub(a, b) when both_numbers(a, b) do
    a.value - b.value
  end

  @doc """
  Multiplies two numbers.

      sig> (* 2 3)
      6

  """
  @spec mult(Literal.t(), Literal.t()) :: Literal.value()
  def mult(a, b) when both_numbers(a, b) do
    a.value * b.value
  end

  @doc """
  Divides two numbers.

      sig> (/ 6 2)
      3

  """
  @spec div(Literal.t(), Literal.t()) :: Literal.value()
  def div(a, b) when both_numbers(a, b) do
    a.value / b.value
  end

  @doc """
  Raise `x` to the power `n`, that is `xⁿ`.

      sig> (^ 2 3)
      8

  """
  @spec pow(Literal.t(), Literal.t()) :: Literal.value()
  def pow(x, n) when both_numbers(x, n) do
    :math.pow(x.value, n.value)
  end

  @doc """
  Square root of `x`.

      sig> (sqrt 4)
      2

  """
  @spec sqrt(Literal.t()) :: Literal.value()
  def sqrt(x) when is_number(x.value) do
    :math.sqrt(x.value)
  end

  @doc """
  Arithmetical absolute value of `a`.

      sig> (abs -3)
      3
      sig> (abs 6)
      6

  """
  @spec abs(Literal.t()) :: Literal.value()
  def abs(x) when is_number(x.value) do
    Kernel.abs(x.value)
  end

  @doc """
  Ratio of the circumference of a circle to its diameter.

  Floating point approximation of mathematical constant π.

      sig> (pi)
      3.14159...

  """
  @spec pi() :: Literal.value()
  defdelegate pi, to: :math

  @doc """
  Ratio of the circumference of a circle to its radius.

  This constant is equivalent to a full turn when described in radians.
  Same as `(* 2 (pi))`.

      sig> (tau)
      6.28318...

  """
  @spec tau() :: Literal.value()
  defdelegate tau, to: :math

  @doc """
  Sine of `x` in radians.

      sig> (sin (pi))
      0

  """
  @spec sin(Literal.t()) :: Literal.value()
  def sin(x) when is_number(x.value) do
    :math.sin(x.value)
  end

  @doc """
  Cosine of `x` in radians.

      sig> (cos (pi))
      -1

  """
  @spec cos(Literal.t()) :: Literal.value()
  def cos(x) when is_number(x.value) do
    :math.cos(x.value)
  end

  @doc """
  Tangent of `x` in radians.

      sig> (tan (/ pi 4))
      1

  """
  @spec tan(Literal.t()) :: Literal.value()
  def tan(x) when is_number(x.value) do
    :math.tan(x.value)
  end

  @doc """
  Inverse sine of `x` in radians.

      sig> (asin 0)
      3.14159...

  """
  @spec asin(Literal.t()) :: Literal.value()
  def asin(x) when is_number(x.value) do
    :math.asin(x.value)
  end

  @doc """
  Inverse cosine of `x` in radians.

      sig> (acos -1)
      3.14159...

  """
  @spec acos(Literal.t()) :: Literal.value()
  def acos(x) when is_number(x.value) do
    :math.acos(x.value)
  end

  @doc """
  Inverse tangent of `x` in radians.

      sig> (atan 0)
      0

  """
  @spec atan(Literal.t()) :: Literal.value()
  def atan(x) when is_number(x.value) do
    :math.atan(x.value)
  end

  @doc """
  Natural (base-e) logarithm of `x`.

      sig> (ln 1)
      0

  """
  @spec ln(Literal.t()) :: Literal.value()
  def ln(x) when is_number(x.value) do
    :math.log(x.value)
  end

  @doc """
  Base-10 logarithm of `x`.

      sig> (log 100)
      2

  """
  @spec log(Literal.t()) :: Literal.value()
  def log(x) when is_number(x.value) do
    :math.log10(x.value)
  end

  @doc """
  Base-`n` logarithm of `a`.

      sig> (logn 2 8)
      3

  """
  @spec logn(Literal.t(), Literal.t()) :: Literal.value()
  def logn(n, x) when both_numbers(n, x) do
    :math.log10(x.value) / :math.log10(n.value)
  end
end
