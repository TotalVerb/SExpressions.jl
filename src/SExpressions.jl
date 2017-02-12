module SExpressions

using Reexport

include("Lists.jl")
include("Keywords.jl")
include("Parser.jl")
include("Htsx.jl")

import .Parser: parse, parses, parsefile
import .Htsx

macro sx_str(x::String)
    parse(x)
end

macro htsx_str(x::String)
    Htsx.tohtml(parses(x))
end

export @sx_str, @htsx_str, Htsx
using SchemeSyntax
Base.@deprecate_binding SimpleJulia SchemeSyntax

end  # module SExpressions
