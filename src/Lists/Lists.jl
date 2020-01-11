"""
Provides a dynamically typed singly-linked list implementation, `List` similar to that
available in most lisp dialects. This module provides basic Julia functionality to
manipulate such lists, exported under both the Julia and Scheme names where they differ
(such as `Base.first` vs. `car`.
"""
module Lists

import FunctionalCollections: append
using Base.Iterators

const car = Base.first

export Cons, List, isnil, ispair, car, cdr, caar, cadr, cddr, nil, append, ++, cons, list,
       islist, Nil

"""
An object representing nothing, or an empty list.

The singleton instance of this type is called `nil`. This type is isomorphic to, and very
similar, to `Nothing`. However, it is often useful to distinguish the `nil` used within many
lisp dialects from a true `Nothing`, because `nil` is iterable and represents an empty list.
"""
struct Nil end
const nil = Nil.instance

"""
An object which is essentially a pair of two objects.

The two objects are referred to, for historical reasons, as `car` and `cdr`.These
abbreviations are not semantically relevant today, so can generally be thought of as the
head object and the tail object. For `Cons` objects which are (proper) lists, the `car`
(head) object will be the first element of the list, and the `cdr` (tail) object will be a
list representing the remaining elements.
"""
struct Cons
    car
    cdr
end
const cons = Cons

car(α::Cons) = α.car
"""
The tail of a `List`.

Note that the tail need not be a list (or even a `List`) if the list is improper.
"""
cdr(α::Cons) = α.cdr
caar(α::Cons) = car(car(α))
cadr(α::Cons) = car(cdr(α))
cddr(α::Cons) = cdr(cdr(α))

Base.map(f, ::Nil, ::Nil...) = nil
Base.map(f, α::Cons, βs::Cons...) =
    Cons(f(car(α), map(car, βs)...), map(f, cdr(α), map(cdr, βs)...))
Base.filter(p, ::Nil) = nil
Base.filter(p, α::Cons) = let β = filter(p, cdr(α))
    p(car(α)) ? Cons(car(α), β) : β
end

Base.:(==)(α::Cons, β::Cons) = car(α) == car(β) && cdr(α) == cdr(β)

"""
An immutable singly linked list, which may be improper.

A list is either `Nil` (empty) or `Cons`, where the first element is an arbitrary object and
the second element is a list. The `List` type, however, includes all instances of `Cons`,
including those for which the second element is not a list. Such `List` instances are called
improper lists, which are allowed because they are used in many lisp dialects.
"""
const List = Union{Cons, Nil}

List() = nil
List(x, xs...) = Cons(x, List(xs...))
const list = List

isnil(::Nil) = true
isnil(::Cons) = false

ispair(α::List) = !isnil(α)

"""
Return `true` if the provided `List` is in fact a list, i.e., it is not improper.

This is the case if the list is a `Nil` (empty list) or a `Cons` with a proper list as its
tail.
"""
islist(::Nil) = true
islist(α::Cons) = islist(cdr(α))

Base.iterate(α::List, β=α) = isnil(β) ? nothing : (car(β), cdr(β))

Base.length(::Nil) = 0
Base.length(α::Cons) = 1 + length(cdr(α))

Base.getindex(α::Nil, b) = throw(BoundsError(α, b))
Base.getindex(α::Cons, b) = b == 1 ? car(α) : cdr(α)[b - 1]

Base.convert(::Type{List}, xs::List) = xs
Base.convert(::Type{List}, xs) = List(xs...)
append(::Nil, β::List) = β
append(α::Cons, β::List) = Cons(car(α), append(cdr(α), β))
append(α::List, β::List, γ::List, γs::List...) = append(append(α, β), γ, γs...)
const (++) = append

include("broadcast.jl")
include("show.jl")

end  # Lists module
