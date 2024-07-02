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
  alias Signo.AST.{Number, Atom, String, List, Nil, Builtin}

  import Signo.Interpreter, only: [truthy?: 1]

  @doc false
  @spec kernel() :: Env.t()
  def kernel do
    %Env{
      scope: %{
        "print" => Builtin.new(:print, 1),
        "inspect" => Builtin.new(:inspect, 1),
        "not" => Builtin.new(:neg, 1),
        "and" => Builtin.new(:both, 2),
        "or" => Builtin.new(:either, 2),
        "nor" => Builtin.new(:neither, 2),
        "xor" => Builtin.new(:xor, 2),
        "==" => Builtin.new(:eq, 2),
        "!=" => Builtin.new(:not_eq, 2),
        ">" => Builtin.new(:gt, 2),
        ">=" => Builtin.new(:gte, 2),
        "<" => Builtin.new(:lt, 2),
        "<=" => Builtin.new(:lte, 2),
        "+" => Builtin.new(:add, 2),
        "-" => Builtin.new(:sub, 2),
        "*" => Builtin.new(:mult, 2),
        "/" => Builtin.new(:div, 2),
        "^" => Builtin.new(:pow, 2),
        "sqrt" => Builtin.new(:sqrt, 1),
        "abs" => Builtin.new(:abs, 1),
        "pi" => Builtin.new(:pi, 0),
        "tau" => Builtin.new(:tau, 0),
        "sin" => Builtin.new(:sin, 1),
        "cos" => Builtin.new(:cos, 1),
        "tan" => Builtin.new(:tan, 1),
        "asin" => Builtin.new(:asin, 1),
        "acos" => Builtin.new(:acos, 1),
        "atan" => Builtin.new(:atan, 1),
        "ln" => Builtin.new(:ln, 1),
        "log" => Builtin.new(:log, 2),
        "logn" => Builtin.new(:logn, 2),
        "length" => Builtin.new(:length, 1),
        "upcase" => Builtin.new(:upcase, 1),
        "downcase" => Builtin.new(:downcase, 1),
        "capitalize" => Builtin.new(:capitalize, 1),
        "trim" => Builtin.new(:trim, 1),
        "concat" => Builtin.new(:concat, 2),
        "first" => Builtin.new(:first, 1),
        "last" => Builtin.new(:last, 1),
        "elem" => Builtin.new(:elem, 2),
        "push" => Builtin.new(:push, 2),
        "pop" => Builtin.new(:pop, 2),
        "sum" => Builtin.new(:sum, 1),
        "product" => Builtin.new(:product, 1),
        "join" => Builtin.new(:join, 2),
      }
    }
  end

  defguardp is_value(a)
    when is_struct(a, Nil)
    or is_struct(a, Number)
    or is_struct(a, Atom)
    or is_struct(a, String)
    or is_struct(a, List)
    or is_struct(a, Lambda)
    or is_struct(a, Builtin)

  defguardp both_numbers(a, b) when is_struct(a, Number) and is_struct(b, Number)
  defguardp both_strings(a, b) when is_struct(a, String) and is_struct(b, String)
  defguardp both_lists(a, b) when is_struct(a, List) and is_struct(b, List)
  defguardp both_values(a, b) when is_value(a) and is_value(b)

  @doc """
  Prints the given argument to stdout, and returns `#ok`.

      sig> (print 10)
      10
      #ok

  """
  @doc section: :general
  @spec print(AST.value()) :: Atom.t()
  def print(value) when is_value(value) do
    value |> IO.puts() |> Atom.new()
  end

  @doc """
  Boolean `not` operator.

  Receives any value (not limited to booleans) and returns `#true` for falsy values,
  and `#false` for truthy ones.

      sig> (not 10)
      #false
      sig> (not ())
      #true

  """
  @doc section: :numbers
  @spec neg(AST.value()) :: Atom.t()
  def neg(literal) when is_value(literal) do
    Atom.new(not truthy?(literal))
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
  @doc section: :operators
  @spec both(AST.value(), AST.value()) :: Atom.t()
  def both(a, b) when both_values(a, b) do
    Atom.new(truthy?(a) and truthy?(b))
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
  @doc section: :operators
  @spec either(AST.value(), AST.value()) :: Atom.t()
  def either(a, b) when both_values(a, b) do
    Atom.new(truthy?(a) or truthy?(b))
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
  @doc section: :operators
  @spec neither(AST.value(), AST.value()) :: Atom.t()
  def neither(a, b) when both_values(a, b) do
    Atom.new(not (truthy?(a) and truthy?(b)))
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
  @doc section: :operators
  @spec xor(AST.value(), AST.value()) :: Atom.t()
  def xor(a, b) when both_values(a, b) do
    Atom.new((truthy?(a) and not truthy?(b)) or (truthy?(b) and not truthy?(a)))
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
  @doc section: :operators
  @spec eq(AST.value(), AST.value()) :: Atom.t()
  def eq(a, b) when both_values(a, b) do
    # TODO(robin): make this work with lambdas and lists
    Atom.new(a.value == b.value)
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
  @doc section: :operators
  @spec not_eq(AST.value(), AST.value()) :: Atom.t()
  def not_eq(a, b) when both_values(a, b) do
    # TODO(robin): make this work with lambdas and lists
    Atom.new(a.value != b.value)
  end

  @doc """
  Greater-than operator.

  Returns `#true` if `a` is greater than `b`.

      sig> (> 3 3)
      #false

  """
  @doc section: :numbers
  @spec gt(Number.t(), Number.t()) :: Atom.t()
  def gt(a, b) when both_numbers(a, b) do
    Atom.new(a.value > b.value)
  end

  @doc """
  Greater-than or equal to operator.

  Returns `#true` if `a` is greater than or equal to `b`.

      sig> (>= 3 3)
      #true

  """
  @doc section: :numbers
  @spec gte(Number.t(), Number.t()) :: Atom.t()
  def gte(a, b) when both_numbers(a, b) do
    Atom.new(a.value >= b.value)
  end

  @doc """
  Less-than operator.

  Returns `#true` if `a` is less than `b`.

      sig> (< 3 3)
      #false

  """
  @doc section: :operators
  @spec lt(Number.t(), Number.t()) :: Atom.t()
  def lt(a, b) when both_numbers(a, b) do
    Atom.new(a.value < b.value)
  end

  @doc """
  Less-than or equal to operator.

  Returns `#true` if `a` is less than or equal to `b`.

      sig> (<= 3 3)
      #true

  """
  @doc section: :operators
  @spec lte(Number.t(), Number.t()) :: Atom.t()
  def lte(a, b) when both_numbers(a, b) do
    Atom.new(a.value <= b.value)
  end

  @doc """
  Adds two numbers.

      sig> (+ 2 3)
      5

  """
  @doc section: :numbers
  @spec add(Number.t(), Number.t()) :: Number.t()
  def add(a, b) when both_numbers(a, b) do
    Number.new(a.value + b.value)
  end

  @doc """
  Substracts two numbers.

      sig> (- 3 2)
      1

  """
  @doc section: :numbers
  @spec sub(Number.t(), Number.t()) :: Number.t()
  def sub(a, b) when both_numbers(a, b) do
    Number.new(a.value - b.value)
  end

  @doc """
  Multiplies two numbers.

      sig> (* 2 3)
      6

  """
  @doc section: :numbers
  @spec mult(Number.t(), Number.t()) :: Number.t()
  def mult(a, b) when both_numbers(a, b) do
    Number.new(a.value * b.value)
  end

  @doc """
  Divides two numbers.

      sig> (/ 6 2)
      3

  """
  @doc section: :numbers
  @spec div(Number.t(), Number.t()) :: Number.t()
  def div(a, b) when both_numbers(a, b) do
    Number.new(a.value / b.value)
  end

  @doc """
  Raise `x` to the power `n`, that is `xⁿ`.

      sig> (^ 2 3)
      8

  """
  @doc section: :numbers
  @spec pow(Number.t(), Number.t()) :: Number.t()
  def pow(x, n) when both_numbers(x, n) do
    Number.new(:math.pow(x.value, n.value))
  end

  @doc """
  Square root of `x`.

      sig> (sqrt 4)
      2

  """
  @doc section: :math
  @spec sqrt(Number.t()) :: Number.t()
  def sqrt(%Number{value: x}) do
    x |> :math.sqrt() |> Number.new()
  end

  @doc """
  Arithmetical absolute value of `a`.

      sig> (abs -3)
      3
      sig> (abs 6)
      6

  """
  @doc section: :math
  @spec abs(Number.t()) :: Number.t()
  def abs(%Number{value: x}) do
    x |> Kernel.abs() |> Number.new()
  end

  @doc """
  Ratio of the circumference of a circle to its diameter.

  Floating point approximation of mathematical constant π.

      sig> (pi)
      3.14159...

  """
  @doc section: :math
  @spec pi() :: Number.t()
  def pi do
    Number.new(:math.pi())
  end

  @doc """
  Ratio of the circumference of a circle to its radius.

  This constant is equivalent to a full turn when described in radians.
  Same as `(* 2 (pi))`.

      sig> (tau)
      6.28318...

  """
  @doc section: :math
  @spec tau() :: Number.t()
  def tau do
    Number.new(:math.tau())
  end

  @doc """
  Sine of `x` in radians.

      sig> (sin (pi))
      0

  """
  @doc section: :math
  @spec sin(Number.t()) :: Number.t()
  def sin(%Number{value: x}) do
    x |> :math.sin() |> Number.new()
  end

  @doc """
  Cosine of `x` in radians.

      sig> (cos (pi))
      -1

  """
  @doc section: :math
  @spec cos(Number.t()) :: Number.t()
  def cos(%Number{value: x}) do
    x |> :math.cos() |> Number.new()
  end

  @doc """
  Tangent of `x` in radians.

      sig> (tan (/ pi 4))
      1

  """
  @doc section: :math
  @spec tan(Number.t()) :: Number.t()
  def tan(%Number{value: x}) do
    x |> :math.tan() |> Number.new()
  end

  @doc """
  Inverse sine of `x` in radians.

      sig> (asin 0)
      3.14159...

  """
  @doc section: :math
  @spec asin(Number.t()) :: Number.t()
  def asin(%Number{value: x}) do
    x |> :math.asin() |> Number.new()
  end

  @doc """
  Inverse cosine of `x` in radians.

      sig> (acos -1)
      3.14159...

  """
  @doc section: :math
  @spec acos(Number.t()) :: Number.t()
  def acos(%Number{value: x}) do
    x |> :math.acos() |> Number.new()
  end

  @doc """
  Inverse tangent of `x` in radians.

      sig> (atan 0)
      0

  """
  @doc section: :math
  @spec atan(Number.t()) :: Number.t()
  def atan(%Number{value: x}) do
    x |> :math.atan() |> Number.new()
  end

  @doc """
  Natural (base-e) logarithm of `x`.

      sig> (ln 1)
      0

  """
  @doc section: :math
  @spec ln(Number.t()) :: Number.t()
  def ln(%Number{value: x}) do
    x |> :math.log() |> Number.new()
  end

  @doc """
  Base-10 logarithm of `x`.

      sig> (log 100)
      2

  """
  @doc section: :math
  @spec log(Number.t()) :: Number.t()
  def log(%Number{value: x}) do
    x |> :math.log10() |> Number.new()
  end

  @doc """
  Base-`n` logarithm of `x`.

      sig> (logn 2 8)
      3

  """
  @doc section: :math
  @spec logn(Number.t(), Number.t()) :: Number.t()
  def logn(n, x) when both_numbers(n, x) do
    Number.new(:math.log10(x.value) / :math.log10(n.value))
  end

  @doc """
  Returns the number of Unicode graphemes in a UTF-8 string.

      sig> (length 'hellö')
      5

  """
  @doc section: :strings
  @spec length(String.t()) :: Number.t()
  def length(%String{value: a}) do
    a |> Elixir.String.length() |> Number.new()
  end

  @doc """
  Converts all characters in the given string to lowercase.

      sig> (downcase 'HELLÖ')
      'hellö'

  """
  @doc section: :strings
  @spec downcase(String.t()) :: String.t()
  def downcase(%String{value: str}) do
    str |> Elixir.String.downcase() |> String.new()
  end

  @doc """
  Converts all characters in the given string to uppercase.

      sig> (upcase 'hellö')
      'HELLÖ'

  """
  @doc section: :strings
  @spec upcase(String.t()) :: String.t()
  def upcase(%String{value: str}) do
    str |> Elixir.String.upcase() |> String.new()
  end

  @doc """
  Converts the first character in the given string to uppercase and the remainder to lowercase.

      sig> (capitalize 'olá')
      'Olá'

  """
  @doc section: :strings
  @spec capitalize(String.t()) :: String.t()
  def capitalize(%String{value: str}) do
    str |> Elixir.String.capitalize() |> String.new()
  end

  @doc """
  Returns a string where all leading and trailing Unicode whitespaces have been removed.

      sig> (trim '   signo  ')
      'signo'

  """
  @doc section: :strings
  @spec trim(String.t()) :: String.t()
  def trim(%String{value: str}) do
    str |> Elixir.String.trim() |> String.new()
  end

  @doc """
  Concatenates two strings or two lists.

      sig> (concat 'hell' 'o')
      'hello'
      sig> (concat (list a b) (list c d))
      <list>(a b c d)

  """
  @doc section: :strings
  @spec concat(String.t(), String.t()) :: String.t()
  def concat(a, b) when both_strings(a, b) do
    a.value <> b.value
  end

  @doc section: :lists
  @spec concat(List.t(), List.t()) :: List.t()
  def concat(a, b) when both_lists(a, b) do
    List.new(a.expressions ++ b.expressions)
  end

  @doc """
  Returns the first item of a list.

      sig> (first (list 'hell' 'o'))
      'hell'

  """
  @doc section: :lists
  @spec first(List.t()) :: AST.value()
  def first(%List{expressions: []}), do: Nil.new()
  def first(%List{expressions: [head | _]}), do: head

  @doc """
  Returns the last item of a list.

      sig> (last (list 'hell' 'o'))
      'o'
      sig> (last (list))
      ()

  """
  @doc section: :lists
  @spec last(List.t()) :: AST.value()
  def last(%List{expressions: expressions}) do
    Elixir.List.last(expressions, Nil.new())
  end

  @doc """
  Returns the last item of a list.

      sig> (elem (list 'hell' 'o') 1)
      'o'
      sig> (elem (list 'hell' 'o') 2)
      ()

  """
  @doc section: :lists
  @spec elem(List.t(), Number.t()) :: AST.value()
  def elem(%List{expressions: expressions}, %Number{value: index}) do
    Enum.at(expressions, index, Nil.new())
  end

  @doc """
  Pushes the given item onto the list.

      sig> (push (list 'hell' 'o') 'world')
      <list>('hell' 'o' 'world')

  """
  @doc section: :lists
  @spec push(List.t(), AST.value()) :: List.t()
  def push(%List{expressions: expressions}, item) when is_value(item) do
    List.new([item | expressions])
  end

  @doc """
  Returns a new list containing the first item of the old list
  and the remainder of the old list.

      sig> (pop (list 'hell' 'o' 'world'))
      <list>('hell' <list>('o' 'world'))
      sig> (tail (list))
      <list>((), <list>())

  """
  @doc section: :lists
  @spec pop(List.t()) :: List.t()
  def pop(%List{expressions: []}) do
    List.new([Nil.new(), List.new([])])
  end

  def pop(%List{expressions: [head | tail]}) do
    List.new([head, List.new(tail)])
  end

  @doc """
  Returns the sum of all `Signo.AST.Number`s in a `Signo.AST.List`.

  Raises `Signo.Interpreter.TypeError` if one of the elements of
  the list is not a number.

      sig> (sum (list 1 2 3))
      6

  """
  @doc section: :lists
  @spec sum(List.t()) :: Number.t()
  def sum(%List{expressions: expressions}) do
    expressions
    |> Enum.reduce(0, fn %Number{value: num}, sum -> num + sum end)
    |> Number.new()
  end

  @doc """
  Returns the product of all `Signo.AST.Number`s in a `Signo.AST.List`.

  Raises `Signo.Interpreter.TypeError` if one of the elements of
  the list is not a number.

      sig> (product (list 2 3 4))
      24

  """
  @doc section: :lists
  @spec product(List.t()) :: Number.t()
  def product(%List{expressions: expressions}) do
    expressions
    |> Enum.reduce(0, fn %Number{value: num}, prod -> prod * num end)
    |> Number.new()
  end

  @doc """
  Joins the given list into a string with the second argument as seperator.

      sig> (join (list 2 3 4) ', ')
      '2, 3, 4'

  """
  @doc section: :lists
  @spec join(List.t(), String.t()) :: String.t()
  def join(%List{expressions: expressions}, %String{value: joiner}) do
    expressions |> Enum.join(joiner) |> String.new()
  end
end
