# SExpressions

[![Build Status](https://travis-ci.org/TotalVerb/SExpressions.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/SExpressions.jl)

## Philosophy

The proliferation of markup and data interchange formats is a huge mistake. The
world would be a simpler and easier place if everyone just used s-expressions.

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
