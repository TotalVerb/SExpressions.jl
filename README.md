# SExpressions

[![Build Status](https://travis-ci.org/TotalVerb/SExpressions.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/SExpressions.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://wafy.me/SExpressions.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://wafy.me/SExpressions.jl/latest)
[![codecov](https://codecov.io/gh/TotalVerb/SExpressions.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/TotalVerb/SExpressions.jl)

## Philosophy

S-expressions simplify many things. Therefore, easy handling of s-expressions is useful.

## Requirements

Although this package is registered, it is not complete. However, the chance of breaking
changes is quite low (as mostly the parser will just be made more permissive, not less), and
any breaking changes will be communicated with a new major version. Julia v1.0 and higher
are supported.

## Parsing and pretty-printing

This package provides a simple recursive descent parser for s-expressions:

```julia
julia> sx"""
       (define (sqr x) (* x x))
       """
(define (sqr x) (* x x))
```

Note that the parser is neither fast nor memory-efficient, but it is simple. It doesn’t
support any fancy features, even those present in most lisps.

As is the convention, a pretty-printed representation is available using the `IOContext`
flag for `:multiline`. Note that this package is “language”-agnostic and won’t format for
any particular language, and doesn’t understand keywords, but rather it will format in
accordance with general principles. Note that this flag is the default on the REPL.

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

In lisp tradition, this package heavily relies on recursion. Of course, this means that you
can probably break it with a stack overflow if you use it on very large data. **It’s also
not fast!** Buyer beware!

## FAQ

### Why is this package not written in a lisp?

[Julia is a lisp.](https://www.youtube.com/watch?v=dK3zRXhrFZY)
