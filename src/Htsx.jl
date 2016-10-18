module Htsx

using ..Lists
using ..Keywords
using ..SimpleJulia
using Hiccup

"""
Return `true` if `α` is a list, and each element in `α` is a list.
"""
islisty(α::List) = all(β -> isa(β, List), α)
islisty(_) = false

function gethiccupnode(head::Symbol, ρ, tmpls)
    if isnil(ρ)
        Node(head, Dict(), [])
    else
        if islisty(car(ρ))  # is a list of attrs
            attrs = Dict(car(β) => cadr(β) for β in car(ρ))
            content = List((tohiccup(ν, tmpls) for ν in cdr(ρ))...)
        else  # is just another body element
            attrs = Dict()
            content = List((tohiccup(ν, tmpls) for ν in ρ)...)
        end
        Node(head, attrs, collect(content))
    end
end

function gethiccupnode(head::Keyword, ρ, tmpls)
    if head == Keyword("template")
        tmpls[car(ρ)::Symbol](cdr(ρ))
    elseif head == Keyword("define-template")
        tmpls[car(ρ)::Symbol] = eval(tojulia(cadr(ρ)))
        Hiccup.TrustedHtml("")  # nothing value
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

tohiccup(s::String, tmpls) = s
tohiccup(i::BigInt, tmpls) = string(i)
tohiccup(x) = tohiccup(x, Dict{Symbol,Any}())

tohtml(α::List) = "<!DOCTYPE html>\n" * string(tohiccup(α))

end
