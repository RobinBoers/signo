# Languages features

## Comments

Everything after `;` to the end of the line will be ignored by the compiler. This space can be used to put comments for future humans reading your program.

```lisp
; this is a comment
(let x 10) ; in JS: let x = 10;
```

## References

You can reference earlier defined variables by their identifier, which we call a *reference* in Signo. Signo is very lax regarding allowed characters in identifiers, allowing all alphanumeric characters, as well as these:
`["_", "=", "+", "-", "*", "/", "^", "%", "#", "&", "@", "!", "?", "~", "<", ">"]`.

The only condition for an identifier is that it cannot start with a digit. The same rules apply for atoms too (but atoms can, unlike identifiers, start with a digit).

See ["Procedures"](procedures.md) for details on how to declare variables.

## Standard library

`Signo.StdLib` contains primitive functions for working with Signo's basic types, comparable the Elixir `Elixir.Kernel`. All functions in `Signo.StdLib` are available in global scope by default, but they can be overriden if you want.