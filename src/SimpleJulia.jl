module SimpleJulia

export tojulia

using ..Lists
using ..Keywords

tojulia(x) = x

function tojulia(α::List)
    if isa(car(α), Keyword)
        Expr(Symbol(car(α).sym), (tojulia ∘ cdr(α))...)
    else
        Expr(:call, (tojulia ∘ α)...)
    end
end

end
