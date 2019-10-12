@reexport module Lists

import FunctionalCollections: append
using Base.Iterators

const car = Base.first

export Cons, List, isnil, ispair, car, cdr, caar, cadr, cddr, nil, lispify,
       append, ++, cons, list, islist, Nil

lispify(x) = x
lispify(b::Bool) = b
lispify(i::Integer) = BigInt(i)
lispify(t::Tuple) = isempty(t) ? nil : Cons(lispify(t[1]), lispify(t[2:end]))

struct Nil end
const nil = Nil.instance

struct Cons
    car
    cdr
end
const cons = Cons

car(α::Cons) = α.car
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

const List = Union{Cons, Nil}

List() = nil
List(xs...) = Cons(lispify(xs[1]), List(xs[2:end]...))
const list = List

isnil(::Nil) = true
isnil(::Cons) = false

ispair(α::List) = !isnil(α)

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
