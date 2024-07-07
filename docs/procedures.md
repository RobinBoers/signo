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

Great question! In Signo there's two ways to declare a list literal:

- Quoting
- `Signo.StdLib.tie/1`

### Quoting

Whenever an expression is preTODO by a quote, it's not directly evaluated. Instead, the AST node is passed as-is, effectively turning program code into data:

```lisp
sig> (let x '(print 10))
(print 10)
```

The variable `x` is now assigned to a list containing the symbol `print` and the number `10`. This list can now be passed around, just like you would pass around any other value:

```lisp
sig> (def hello (thing) (print thing))
<lambda>(thing -> ...)
sig> (hello x)
(print 10)
```

And it can be manipulated with Standard Library functions, such as `Signo.StdLib.push/1`:

```lisp
sig> (push 'hello' x)
('hello' print 10)
```

The list can be turned back into program code by evaluating it using `Signo.SpecialForms._eval/2`:

```lisp
sig> (eval x)
10
#ok
```

### Tie-ing

Another way to create lists is using `Signo.StdLib.tie/1`. The difference here is that `tie` evaluated the arguments before turning them into a list, meaning `print` will be resolved before being put into the list:

```lisp
sig> (tie print 10)
(<builtin>(print) 10)
```