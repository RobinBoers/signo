# Procedures

Everything we've discussed up to this point has been about **atomics**. Atomics are the individual building blocks that make up Signo:

- Literals, such as `100`, `1.0`, `#true`, `"hello world"` and `#ok`.
- References to previously defined variables or functions.
- Keywords, like `let`, `if`, `def`, `lambda`, and `do`.

Together they form space-seperated lists called procedures, such as: `(print "hello" 100 "worlds")`. What the procedure evaluates to is determinded based on the first atomic (keyword or reference):

- `(let $name $value)` puts a reference in scope, and returns the assigned value.
- `(if $cond $then $else)` branches the control flow based on the given condition.
- `(lambda $args $body)` evaluates to a callable function.
- `(def $name $args $body)` is syntatic sugar for `(let $name (lambda $args $body))`.
- `($name $args...)` calls a function and returns the evaluated body.

In Signo, everything is an expression. That means every procedure evaluates to
*something*, so blocks of expressions can be nested.

Here's a quick example:

```lisp
sig(1)> (def add (a) (lambda (b) (+ a b)))
sig(2)> ((add 2) 3)
5
```

As you can see, the subprocedure evaluates to a lambda which is then called with the argument `3`, together adding up to `5`. This expression-based approach makes Signo extremely flexible and versatile.

Furthermore, Signo is entirely immutable. While a variable can be reassigned within
scope, a reference to a variable can never be mutated and then used elsewhere.

```lisp
(let x 10)
(some-long-running-thing x)
(let x 20) ; x reassigned here, but x in some-long-running-thing is still 10
(print x) ; likewise, changing x in some-long-running-thing doesn't change it's value here
```
