import Base: copy
import Base.Broadcast:
    AbstractArrayStyle, Broadcasted, BroadcastStyle, Style, broadcastable, instantiate,
    flatten

# For broadcasting, we think of Lists as being more complex than a 0-dimensional object but
# less complex than a 1-dimensional one (since we lack size). Note that this doesn’t
# actually work for broadcasting with arrays — since Lists don’t implement the array
# interface. This is not an easy problem to resolve.
BroadcastStyle(::Type{<:List}) = Style{List}()
BroadcastStyle(::Style{List}, ::AbstractArrayStyle{0}) = Style{List}()
BroadcastStyle(::Style{List}, s::AbstractArrayStyle{N}) where {N} = s

broadcastable(α::List) = α
instantiate(bc::Broadcasted{Style{List}}) = bc

# This implementation of copy is essentially the same as the implementation of map, except
# that the “only” elements are treated as infinite lists that are nil whenever necessary.
isnil_or_only(::Cons) = false
isnil_or_only(::Any) = true

car_or_only(α::List) = car(α)
car_or_only(x) = x[]

cdr_or_only(α::List) = cdr(α)
cdr_or_only(x) = x

function map_or_only(f, ::Nil, xs...)
    for x in xs
        if !isnil_or_only(xs)
            throw(ArgumentError("not all lists are of equal length"))
        end
    end
    nil
end
map_or_only(f, x::Cons, xs...) =
    Cons(f(car(x), map(car_or_only, xs)...),
         map_or_only(f, cdr(x), map(cdr_or_only, xs)...))

# Pull the scalar out so we may rely on dispatch to determine if the map is empty
map_or_only(f, x, xs...) = map((ys...) -> f(x, ys...), xs...)

function copy(bc::Broadcasted{Style{List}})
    f = flatten(bc)
    map_or_only(f.f, f.args...)
end
