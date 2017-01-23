"""
Htsx tagging system.
"""
module Tags  # TODO: needs tests

using Base.Iterators
using DataStructures

immutable TagMatrix
    popularity::DefaultDict{String,Int,Int}
    correlation::DefaultDict{Tuple{String,String},Int,Int}
    TagMatrix() = new(
        DefaultDict{String, Int}(0),
        DefaultDict{Tuple{String,String}, Int}(0))
end

"""
    tags(m::TagMatrix)

Return an iterable over all tags seen in the TagMatrix `m`.
"""
tags(m::TagMatrix) = keys(m.popularity)

"""
    popularity(m::TagMatrix, t::AbstractString)

Return the popularity of tag `t` in `m`.
"""
popularity(m::TagMatrix, t) = m.popularity[t]

"""
    popular(m::TagMatrix)

Return a `Vector` of tags, ordered from most popular to least.
"""
popular(m::TagMatrix) = sort(collect(tags(m)), by=t -> -popularity(m, t))

"""
    joint(m::TagMatrix, t1, t2)

Return the total weight of entries which have both `t1` and `t2` as tags.
"""
joint(m::TagMatrix, t1, t2) = m.correlation[tuple(sort([t1, t2])...)]

"""
    relatedto(m::TagMatrix, tag, num=8)

Return up to the top `num` tags related to `tag`.
"""
function relatedto(m::TagMatrix, t, num=8)
    top = [(tag, joint(m, t, tag) / (m.popularity[tag] + 2))
           for tag in keys(m.popularity) if tag != t]
    filter!(x -> x[2] > 0, top)
    sort!(top, by=x -> -x[2])
    take(top, num)
end

"""
    populate!(m::TagMatrix, tags, value=1)

Add an entry to the tag matrix, whose tags are given by `tags`, and whose
weight is given by `value`.
"""
function populate!(m::TagMatrix, tags, value)
    for tag in tags
        m.popularity[tag] += value
        for tag2 in tags
            if tag2 > tag
                m.correlation[(tag, tag2)] += value
            end
        end
    end
end

export TagMatrix, joint, relatedto, populate!, popular

end
