module StdLib

import ..MarkdownHtsx.render

rendermd(x) = render(Base.Markdown.parse(x))

"""
Htsx tagging system.
"""
module Tags  # TODO: needs tests

using DataStructures

immutable TagMatrix
    popularity::DefaultDict{String,Int,Int}
    correlation::DefaultDict{Tuple{String,String},Int,Int}
    TagMatrix() = new(
        DefaultDict(String, Int, 0),
        DefaultDict(Tuple{String,String}, Int, 0))
end

joint(m::TagMatrix, t1, t2) = m.correlation[tuple(sort([t1, t2])...)]

function relatedto(m::TagMatrix, t)
    top = [(tag, joint(m, t, tag) / (m.popularity[tag] + 2))
           for tag in keys(m.popularity) if tag != t]
    filter!(x -> x[2] > 0, top)
    sort!(top, by=x -> -x[2])
    take(top, 5)
end

end

end
