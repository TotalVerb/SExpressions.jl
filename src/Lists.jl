@reexport module Lists

export Cons, List, isnil, ispair, car, cdr, caar, cadr, cddr, nil, lispify, ∘

f ∘ g::Function = x -> f(g(x))
f ∘ g           = map(f, g)

lispify(x) = x
lispify(::Void) = nil
lispify(i::Integer) = BigInt(i)
lispify(t::Tuple) = isempty(t) ? nil : Cons(lispify(t[1]), lispify(t[2:end]))

immutable Nil end
const nil = Nil.instance

immutable Cons
    car
    cdr
end

car(α::Cons) = α.car
cdr(α::Cons) = α.cdr
caar(α::Cons) = car(car(α))
cadr(α::Cons) = car(cdr(α))
cddr(α::Cons) = cdr(cdr(α))

Base.map(f, ::Nil) = nil
Base.map(f, α::Cons) = Cons(f(car(α)), f ∘ cdr(α))

Base.:(==)(α::Cons, β::Cons) = car(α) == car(β) && cdr(α) == cdr(β)

typealias List Union{Cons, Nil}

List() = nil
List(xs...) = Cons(lispify(xs[1]), List(xs[2:end]...))

isnil(::Nil) = true
isnil(::Cons) = false

ispair(α::List) = !isnil(α)

Base.start(α::List) = α
Base.next(::List, β::List) = car(β), cdr(β)
Base.done(::List, β::List) = isnil(β)

Base.length(::Nil) = 0
Base.length(α::Cons) = 1 + length(cdr(α))

unparse(α::List) = "(" * join(unparse ∘ α, " ") * ")"
unparse(s::Symbol) = string(s)
unparse(s::String) = repr(s)
unparse(i::BigInt) = string(i)

include("lists/show.jl")

end  # Lists module