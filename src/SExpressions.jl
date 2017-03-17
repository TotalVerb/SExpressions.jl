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
const Htsx = Remarkable.Remark
macro htsx_str(x::String)
    Htsx.tohtml(parses(x))
end

export @sx_str, @htsx_str, Htsx

end  # module SExpressions
