# Appendix: Example program

```lisp
; this is a comment

; variable definition and expressionism
(print (let meaningOfTheUniverse 42))
(print (* 2 meaningOfTheUniverse))

; operators
(let coolNumber 69.420)
(print (and coolNumber #true))

; simple function definitions
(def double (n) (* 2 n))
(let result (double 8))

; if-expressions
(if (== result 16) (print "it works!") (print "it doesnt!"))

; the environment is 'enclosed' in a function upon definition
; if it get's changed later, the function will retain values
; as they were on definition. aka calling (closure 6) after
; changing 'result' should not change behaviour.
(def closure (n) (+ n result))
(let result 2)
(print (if (== 18 (closure 2)) "omg closures!"))

; () is our nil type.
; this does nothing
(if (not #false) () (print "oops!"))

; this is a convoluted way to print; but it works!
((lambda (n) (print n)) (join '("hello" "world!") ", "))

; lists :)
(let x '(1 2))
(let x (push 3 x))
(print (sum x))

; recursion
; tail recursion not implemented...
(def fact (n) (if (!= n 1) (* n (fact (- n 1))) 1))
(print (fact 4))

; this is a block: the last expression will be returned, and 
; it has a seperate scope, but inherits from global scope
(print (do
  (print "hello from scope!")
  (let y (* 2 coolNumber))))

; y is undefined here because it's only defined in the block scope
(print "gonna crash now...")
(print y)
```