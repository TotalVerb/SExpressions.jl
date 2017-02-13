# SExpressions

[![Build Status](https://travis-ci.org/TotalVerb/SExpressions.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/SExpressions.jl)

## Philosophy

The world would be a simpler and easier place if everyone just used
s-expressions.

## Requirements

This package is not yet listed. Install at your own peril. It also requires a
master Julia.

## Parsing and pretty-printing

This package provides a simple recursive descent parser for s-expressions:

```julia
julia> sx"""
       (define (sqr x) (* x x))
       """
(define (sqr x) (* x x))
```

Note that the parser is neither fast nor memory-efficient, but it is simple. It
doesn’t support any fancy features, even those present in most lisps.

As is the convention, a pretty-printed representation is available using the
`IOContext` flag for `:multiline`. Note that this package is “language”-agnostic
and won’t format for any particular language, and doesn’t understand keywords,
but rather it will format in accordance with general principles. Note that this
flag is the default on the REPL.

```julia
julia> sx"""
       (define multiply-by-four-and-add-five
         (let ([four 4]
               [five 5])
           (λ (x) (+ (* x four) five))))
       """
(define
  multiply-by-four-and-add-five
  (let ((four 4) (five 5)) (λ (x) (+ (* x four) five))))
```

This is not fast either. This package is not intended for huge files containing
s-expressions.

## HTML

This package provides a way to write HTML pages using terse s-expression syntax.
This functionality is named HTSX, for Hypertext S-Expressions. The code:

```racket
(html ([lang "en"])
    (head (title "Hello World!"))
    (body (p "This is my first HTSX page.")))
```

turns into

```html
<!DOCTYPE html>
<html lang="en"><head><title>Hello World!</title></head><body><p>This is my first HTSX page.</p></body></html>
```

To use HTSX, use the `@htsx_str` string macro:

```julia
htsx"""
(html ([lang "en"])
    (title "Hello World!")
    (p "This is an example of the " (code "@htsx_str") " string macro."))
"""
```

## Internals

In lisp tradition, this package heavily relies on recursion. Of course, this
means that you can probably break it with a stack overflow if you use it on very
large data. It's also not super fast.

Code minimalism is an important aim.

## FAQ

### Why is this package not written in a lisp?

[Julia is a lisp.](https://www.youtube.com/watch?v=dK3zRXhrFZY)
