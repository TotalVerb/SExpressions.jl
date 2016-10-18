module SimpleJulia

export tojulia

using ..Lists
using ..Keywords

tojulia(x) = x

const _IMPLICIT_KEYWORDS = Dict(
    :(=) => :(=))

function tojulia(α::List)
    if isa(car(α), Keyword)
        Expr(Symbol(car(α).sym), (tojulia ∘ cdr(α))...)
    elseif car(α) in _IMPLICIT_KEYWORDS
        Expr(_IMPLICIT_KEYWORDS[α], (tojulia ∘ cdr(α))...)
    else
        Expr(:call, (tojulia ∘ α)...)
    end
end

end
