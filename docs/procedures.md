# Lists & procedures

Everything we've discussed up to this point has been about **atomics**. They are the core building blocks that make up Signo programs:

- Literals, such as `100`, `1.0`, `#true`, `"hello world"` and `#ok`.
- References to previously defined variables or functions.

While all fun and games, you can't write a meaningful program using just literal values. But when grouped into lists, we can do some pretty cool stuff. But first(!): let's talk about expressions.

## Expressions

Signo is an expression-based language. That means that everything in Signo can be evaluated down to some kind of *value*, being:

- A literal value.
- A callable function or macro.

In total, Signo has three types of expressions:

- Values, which can't be further evaluated.
- Symbols, which evaluate to some earlier defined value.
- Procedures, in which the tail of a list gets applied to its head.

Because everything is an expression, everything evaluates to *something*, meaning blocks of expressions can be nested.

Here's a quick example:

```lisp
sig(1)> (def add (a) (lambda (b) (+ a b)))
sig(2)> ((add 2) 3)
5
```

As you can see, the subprocedure evaluates to a lambda which is then called with the argument `3`, together adding up to `5`. This expression-based approach makes Signo extremely flexible and versatile.

## Procedure

Whenever Signo encounters a list, the head of the list is assumed to be a callable value, and the tail of the list is assumed to be a list of arguments. The arguments get applied to the callable, which returns a value. 

We call this a procedure. In Signo, there's three different types of callables:

- Builtin functions, from `Signo.StdLib`.
- Macros, which form language constructs, defined in `Signo.SpecialForms`.
- User-defined functions.

## Quoting & meta-programming

A perceptive reader might now wonder: how does one introduce an actual list in ones program, if lists are always treated as function calls? 

Great question! Most Lisp dialects solve this by using the quoting mechanism. Simply put, the quote prevents a list--or any expression for that matter--from being evaluated. Instead, the node is passed as-is, effectively turning program code into data:

```lisp
sig> (let x '(something 10))
(something 10)
```

> #### Some more playing around {: .neutral}
> The variable `x` is now assigned to a list containing the symbol `print` and the number `10`. This list can be passed around, just like you would pass around any other value:
>
> ```lisp
> sig> (def hello (thing) (print thing))
> <lambda>(thing -> ...)
> sig> (hello x)
> (something 10)
> ```
> 
> It can be turned back into program code by evaluating it using `Signo.SpecialForms._eval/> 2`. But since `something` is not defined within current scope, that will raise a > ReferenceError:
> 
> ```lisp
> sig> (eval x)
> [ReferenceError] 'something' is undefined at nofile:1:7
> ```
>
> (However, if we define `something` beforehand, or pass some other Standard Library function, such as `print`, this would work :))

This may alert the observant reader once again; what if I want to create a list out of a set of expressions? Because if the quote stops the expression from evaluating, any nested expressions will stay untouched too. And that's correct:

```lisp
sig> '(1 2 (+ 1 2))
(1 2 (+ 1 2))
```

That's what the `Signo.StdLib.tie/1` function is for. The difference here is that `tie` evaluates the arguments before turning them into a list, meaning `(+ 1 2)` will be resolved before being put into the list:

```lisp
sig> (tie 1 2 (+ 1 2))
(1 2 3)
```