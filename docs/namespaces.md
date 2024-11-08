# Namespaces

While single-file programs are fine for small utilities and scripts, bigger projects often require splitting code into standlone modules, and sharing code between those modules.

For this purpose, Signo has two builtin language constructs:

- `include` reads an external file and evaluates it, mutating global scope. Think of it as dropping the external code into the current file, ala C.

- `import` works similarly, but rather than exposing and mutating global scope, the file gets evaluated in an isolated environment and the resulting scope gets merged into global scope under a namespace.

The namespace acts as a prefix for all identifiers in the resulting `Signo.Env`. Namespaced references contain a `:` character, separating the namespace from the original identifier.

```signo
# coords.sg
(let x 10)
(let y 20)

# main.sg
(import "coords.sg" as coords)
(+ coords:x coords:y) # => 30
```

If you omit the `as`-clause, the namespace will be inferred from the filename. If the namespace already exists, it will be masked, similar to how variables are usually masked. Also, the `as`-clause accepts both symbols, as well as strings.

When importing a file, namespaced references from that file will be omitted:

```signo
# utils.sg
(def hello () (print "hello!"))

# coords.sg
(import "utils.sg")
(let x 10)
(let y 20)

# main.sg
(import "coords.sg" as coords)
(+ coords:x coords:y) # => 30
(coords:utils:hello) # => [ReferenceError] 'coords:utils:hello' is undefined
```

It is not possible to directly assign to a namespace either:

```signo
(let coords:x 10) # => [DefinitionError] 'coords:x' is an illegal reference
```
