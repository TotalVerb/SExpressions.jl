module SExpressions
using Reexport

include("scheme.jl")
include("parser.jl")

import .Parser: parse

macro sx_str(x::String)
    parse(x)
end

export @sx_str

end  # module SExpressions
