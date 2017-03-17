__precompile__()
module SExpressions

using Reexport

include("Lists/Lists.jl")
include("Keywords/Keywords.jl")
include("Parser/Parser.jl")

import .Parser: parse, parses, parsefile

macro sx_str(x::String)
    parse(x)
end

export @sx_str

end  # module SExpressions
