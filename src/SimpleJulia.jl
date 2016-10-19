module SimpleJulia

export tojulia

using ..Lists
using ..Keywords

tojulia(x) = x

const _IMPLICIT_KEYWORDS = Dict(
    :(=) => :(=),
    :if => :if,
    :while => :while,
    :begin => :block)

function tojulia(α::List)
    if isa(car(α), Keyword)
        Expr(Symbol(car(α).sym), (tojulia ∘ cdr(α))...)
    elseif haskey(_IMPLICIT_KEYWORDS, car(α))
        Expr(_IMPLICIT_KEYWORDS[α], (tojulia ∘ cdr(α))...)
    else
        Expr(:call, (tojulia ∘ α)...)
    end
end

end
