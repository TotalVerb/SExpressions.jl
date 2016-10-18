module Keywords

using ..Lists
import ..Lists.unparse

export Keyword

immutable Keyword
    sym::String
end
Base. ==(x::Keyword, y::Keyword) = x.sym == y.sym

unparse(kw::Keyword) = string(kw)
Base.show(io::IO, kw::Keyword) = print(io, "#:", kw.sym)

end
