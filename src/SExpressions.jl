module SExpressions
using Reexport

include("lists.jl")
include("parser.jl")
include("Htsx.jl")

import .Parser: parse
import .Htsx

macro sx_str(x::String)
    parse(x)
end

macro htsx_str(x::String)
    Htsx.tohtml(parse(x))
end

export @sx_str, @htsx_str, Htsx

end  # module SExpressions
