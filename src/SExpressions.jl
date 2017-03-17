module SExpressions

using Reexport

include("Lists.jl")
include("Keywords.jl")
include("Parser.jl")

import .Parser: parse, parses, parsefile

macro sx_str(x::String)
    parse(x)
end

using Remarkable

export @sx_str

end  # module SExpressions
