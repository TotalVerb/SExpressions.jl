__precompile__()
module SExpressions

using Reexport

include("Lists/Lists.jl")
include("Keywords/Keywords.jl")
include("Parser/Parser.jl")

export SExpression
import .Parser: parse, parseall, parsefile, SExpression
@reexport using .Lists

macro sx_str(x::String)
    QuoteNode(parse(x))
end

export @sx_str

end  # module SExpressions
