# Introduction

Welcome!

This guide will attempt to teach you my lil' Lisp variant, Signo. It's a Lisp-based language, interpreted in Elixir. In the future I'm planning on basic Elixir-interop and maybe even running it on the BEAM directly, by compiling to Erlang byte code.

Anyway. This guide will show you how to get up-and-running.

## Installation

Since Signo is interpreted using Elixir, which is in turn compiled to Erlang, you need to download both Elixir and Erlang. Take a look at [their installation guides](https://elixir-lang.org/install.html) first.

After you've set that all up, you can download Signo via `git clone`:

```shell
git clone https://git.dupunkto.org/axcelott/signo.git
cd signo
mix compile
```

## Interactive Signo

You can open a REPL (read-evaluate-print loop) by entering `mix repl`:

```
$ mix repl
Erlang/OTP 26 [erts-14.2.1] [source] [64-bit] [smp:11:11] [ds:11:11:10] [async-threads:1] [jit]

Interactive Signo v0.1.0 (Elixir/1.16.2)
sig(1)> 40 + 2
42
sig(2)> 'hello world!'
'hello world!'
```

Go ahead and type some expressions! To exit the REPL, press `Ctrl+C` twice.

## Running programs

Typing stuff into that REPL is all good fun, but what if you're wanting to write some *real* programs? Well, don't worry, I've got you covered!

Open up your favorite text editor and write something along these lines to a file creatively named `hello.sg`:

```lisp
(print 'hello, world!')
```

And then run it like this:

```
$ mix execute hello.sg
hello, world!
```

With all that out of the way, let's look at some of Signo's basic types!