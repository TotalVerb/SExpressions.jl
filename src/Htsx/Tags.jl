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

joint(m::TagMatrix, t1, t2) = m.correlation[tuple(sort([t1, t2])...)]

function relatedto(m::TagMatrix, t)
    top = [(tag, joint(m, t, tag) / (m.popularity[tag] + 2))
           for tag in keys(m.popularity) if tag != t]
    filter!(x -> x[2] > 0, top)
    sort!(top, by=x -> -x[2])
    take(top, 5)
end

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
