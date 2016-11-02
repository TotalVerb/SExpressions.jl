module SimpleJulia

export tojulia

using ..Lists
using ..Keywords

tojulia(x) = x
function tojulia(x::Symbol)
    xstr = string(x)
    Symbol(xstr[end] == '?' ? "is" * xstr[1:end-1] : xstr)
end

const _IMPLICIT_KEYWORDS = Dict(
    :(=) => :(=),
    :if => :if,
    :while => :while,
    :begin => :block)

quasiquote(x) = x
quasiquote(x::Symbol) = Meta.quot(x)
function quasiquote(α::List)
    if car(α) == :unquote
        tojulia(cadr(α))
    else
        Expr(:call, :List, map(quasiquote, α)...)
    end
end

function tojulia(α::List)
    if isa(car(α), Keyword)
        Expr(Symbol(car(α).sym), (tojulia ∘ cdr(α))...)
    elseif car(α) == :quote
        Meta.quot(cadr(α))
    elseif car(α) == :quasiquote
        quasiquote(cadr(α))
    elseif haskey(_IMPLICIT_KEYWORDS, car(α))
        Expr(_IMPLICIT_KEYWORDS[car(α)], (tojulia ∘ cdr(α))...)
    else
        Expr(:call, (tojulia ∘ α)...)
    end
end

end
