# Basic types

Signo's basic types are: numbers, atoms, booleans, strings, and nil. Lists will be discussed seperately later.

```
sig> 1            ; number
sig> 2.0          ; number
sig> #true        ; boolean
sig> #ok          ; atom
sig> "signo"      ; string
```

## Numbers

Unlike other languages, Signo does not differentiate between integers and floats, instead opting for one universal `number` type. Internally, they are saved as Elixir `t:integer/0` and `t:float/0`, which means floats are 64-bit precision.

## Atoms & booleans

An atom is a constant whose value is its own name. Some other languages call these symbols or enums. They are often useful to enumerate over distinct values, such as: `#ok, #error, #not-found`. 

An atom is like an integer: it is itself. `1` is not anything else than just `1`; likewise, `#apple` is nothing else than `#apple`. Often they are used to express the state of an operation, by using values such as `#ok`, `#pending`, and `#error`.

In Signo, booleans are represented as atoms too, just like in Elixir. However, unlike in Elixir, you're not allowed to skip the leading `#`.

```
#true
#false
```

Atoms are equal if their names are equal.

```
sig> (== #banana #banana)
#true
```

## Strings

Strings in Signo are delimited by **double** quotes, and they are encoded in UTF-8:

```
sig> "hellö"
"hellö"
```

Strings can be concatenated using the `Signo.StdLib.concat/2` function from the standard library:

```
sig> (concat "hell" "o")
"hello"
```

You can print a string using the `Signo.StdLib.print/1` function:

```
sig> (print "hello")
"hello"
```

## Nil

In Signo, nil is represented as an empty list:

```
sig> ()
()
```

Nil is the only non-boolean value that is falsy. So unlike other languages, where `""` and `0` are often falsy too, the only two falsy values in Signo are `#false` and `()`.
