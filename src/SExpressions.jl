__precompile__()
module SExpressions

using Reexport

include("Lists/Lists.jl")
include("Keywords/Keywords.jl")
include("Parser/Parser.jl")

import .Parser: parse, parseall, parsefile

Base.@deprecate_binding parses parseall

macro sx_str(x::String)
    QuoteNode(parse(x))
end

export @sx_str

end  # module SExpressions
