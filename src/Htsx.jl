module Htsx

using ..Lists
using Hiccup

"""
Return `true` if `α` is a list, and each element in `α` is a list.
"""
islisty(α::List) = all(β -> isa(β, List), α)
islisty(_) = false

function tohiccup(α::List)
    len = length(α)
    if len < 1
        error("Empty list not allowed here")
    else
        head = car(α)::Symbol
        ρ = cdr(α)
        if isnil(ρ)
            Node(head, Dict(), [])
        else
            if islisty(car(ρ))  # is a list of attrs
                attrs = Dict(car(β) => cadr(β) for β in car(ρ))
                content = tohiccup ∘ cdr(ρ)
            else  # is just another body element
                attrs = Dict()
                content = tohiccup ∘ ρ
            end
            Node(head, attrs, collect(content))
        end
    end
end

tohiccup(s::String) = s
tohiccup(i::BigInt) = string(i)

tohtml(α::List) = "<!DOCTYPE html>\n" * string(tohiccup(α))

end
