"""
    readsize(io::IO, c)

Return the number of bytes that would be read if `c` were read from `io`.
"""
readsize(_::IO, x::Union{Base.BitInteger, Float16, Float32, Float64}) =
    sizeof(x)
readsize(_::IO, c::Char) = @static VERSION < v"1.1.0" ? Base.codelen(c) : ncodeunits(c)

"""
    peek(io::IO, T::Type)

Read a `T` (`UInt8` or `Char`) from `io` without changing its state. This
function may be implemented by putting the read value back to the stream `io`.
"""
function peek(io::IO, T::Type)
    char = read(io, T)
    skip(io, -readsize(io, char))
    char
end
