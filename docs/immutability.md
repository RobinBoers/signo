# Immutability

Lastly, Signo is entirely immutable. While a variable can be reassigned within
scope, a reference to a variable can never be mutated and then used elsewhere.

```lisp
(let x 10)
(some-long-running-thing x)
(let x 20) ; x reassigned here, but x in some-long-running-thing is still 10
(print x) ; likewise, changing x in some-long-running-thing doesn't change it's value here
```