module Keywords

export Keyword

import Base: ==, hash
using ..Lists
import ..Lists.unparse

immutable Keyword
    sym::String
end
x::Keyword == y::Keyword = x.sym == y.sym
hash(x::Keyword, n::UInt) = hash(Keyword, hash(x.sym, n))

unparse(kw::Keyword) = string(kw)
Base.show(io::IO, kw::Keyword) = print(io, "#:", kw.sym)

end
