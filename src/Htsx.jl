module Htsx

module Environment

using ...Lists
using ...Keywords
using ...SimpleJulia
using Hiccup

end

using ..Lists
using ..Keywords
using ..SimpleJulia
using Hiccup
using FunctionalCollections

setindex(x, y, z) = assoc(x, z, y)

"""
Return `true` if `α` is a list, and each element in `α` is a list.
"""
islisty(α::List) = all(β -> isa(β, List), α)
islisty(_) = false

"""
Monad-ish: thread second argument through successive calls of `f` to elements
of `xs`.
"""
function acc2(f, xs, acc)
    res = []
    for x in xs
        r, acc = f(x, acc)
        push!(res, r)
    end
    res, acc
end

function gethiccupnode(head::Symbol, ρ, tmpls)
    if isnil(ρ)
        Node(head, Dict(), []), tmpls
    else
        if islisty(car(ρ))  # is a list of attrs
            attrs = Dict(car(β) => cadr(β) for β in car(ρ))
            content, tmpls = acc2(tohiccup, cdr(ρ), tmpls)
        else  # is just another body element
            attrs = Dict()
            content, tmpls = acc2(tohiccup, ρ, tmpls)
        end
        Node(head, attrs, collect(content)), tmpls
    end
end

function gethiccupnode(head::Keyword, ρ, tmpls)
    if head == Keyword("template")
        tohiccup(tmpls[car(ρ)::Symbol](cdr(ρ)...), tmpls)
    elseif head == Keyword("var")
        tmpls[car(ρ)::Symbol], tmpls
    elseif head == Keyword("define")
        fn = tojulia(car(ρ))
        if !Meta.isexpr(fn, :call)
            error("wrong define syntax")
        end
        newfn = eval(Environment,
            Expr(:function, Expr(:tuple, fn.args[2:end]...),
            tojulia(cadr(ρ))))
        html"", setindex(tmpls, newfn, fn.args[1])  # nothing value
    else
        error("Unsupported HTSX keyword $head")
    end
end

function tohiccup(α::List, tmpls)
    len = length(α)
    if len < 1
        error("Empty list not allowed here")
    else
        head = car(α)
        gethiccupnode(head, cdr(α), tmpls)
    end
end

tohiccup(s::String, tmpls) = s, tmpls
tohiccup(i::BigInt, tmpls) = string(i), tmpls

tohiccup(x, tmpls) = error("Can’t serialize $(repr(x))")

function tohiccups(α::List, tmpls)
    parts = []
    for β in α
        res, tmpls = tohiccup(β, tmpls)
        push!(parts, res)
    end
    parts
end

tohtml(α::List, tmpls=PersistentHashMap{Symbol,Any}()) = "<!DOCTYPE html>\n" *
    join(string ∘ tohiccups(α, tmpls))

end
