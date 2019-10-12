# Simple recursive descent parser

module Parser

using Base.Iterators
using ..Lists
using ..Keywords
import Base: convert

export parse, SExpression

"""
Union type of all types allowed in primitive s-expressions. The output of `parse` is
guaranteed to be an `SExpression`.
"""
const SExpression =
    Union{BigInt,
          Float64,
          Rational{BigInt},
          Complex{BigInt},
          Complex{Float64},
          Complex{Rational{BigInt}},
          Nothing,
          Bool,
          String,
          Symbol,
          List}

convert(::Type{SExpression}, x::Integer) = BigInt(x)
convert(::Type{SExpression}, x::AbstractFloat) = Float64(x)
convert(::Type{SExpression}, x::Rational) = Rational{BigInt}(x)
convert(::Type{SExpression}, x::Complex{<:Integer}) = Complex{BigInt}(x)
convert(::Type{SExpression}, x::Complex{<:AbstractFloat}) = Complex{Float64}(x)
convert(::Type{SExpression}, x::Complex{<:Rational}) = Complex{Rational{BigInt}}(x)
convert(::Type{SExpression}, x::AbstractString) = String(x)
convert(::Type{SExpression}, xs::Tuple) = List(convert.(SExpression, xs)...)
convert(::Type{SExpression}, xs::AbstractVector) = List(convert.(SExpression, xs)...)
SExpression(x) = convert(SExpression, x)

include("numeric.jl")
include("util.jl")

const _DELIMITERS = collect("()[]{}\",'`;")

const _NEWLINE = (
        '\u000D', '\u000A', '\u0085', '\u000B', '\u000C', '\u2028', '\u2029')
isnewline(c) = c ∈ _NEWLINE

const _CLOSE = Dict('(' => ')', '[' => ']', '{' => '}', '"' => '"')
closer(c) = _CLOSE[c]

const _READER_MACROS = Dict(
    '\'' => :quote,
    '`' => :quasiquote,
    ',' => :unquote)

const _ESCAPED = Dict('a' => '\x07', 'b' => '\x08', 't' => '\x09',
                      'n' => '\x0a', 'v' => '\x0b', 'f' => '\x0c',
                      'r' => '\x0d', 'e' => '\x1b', '"' => '"',
                      '\'' => '\'', '\\' => '\\')

isdelimiter(c) = isspace(c) || c in _DELIMITERS

macro syntaxcheck(ex)
    quote
        if !$(esc(ex))
            # TODO improve the error messages
            error("invalid syntax")
        end
    end
end

"""
    skipws(io::IO)

Skip all whitespace characters at beginning of the given `io` object.
"""
function skipws(io::IO)
    while !eof(io)
        c = read(io, Char)
        if !isspace(c)
            skip(io, -readsize(io, c))
            return
        end
    end
end

"""
    readsymbol(io::IO)

Read up until the next delimiter.
"""
function readsymbol(io::IO)
    buf = IOBuffer()
    while !eof(io)
        c = read(io, Char)
        if isdelimiter(c)
            skip(io, -readsize(io, c))
            return String(take!(buf))
        end
        write(buf, c)
    end
    String(take!(buf))
end

"""
A dot as in (a . b).
"""
struct Dot end

"""
Build an improper list (a b . c).
"""
function improperlist(prefix, terminal)
    if isempty(prefix)
        terminal
    else
        Cons(prefix[1], improperlist(prefix[2:end], terminal))
    end
end

"""
Check that there are no . in objs, and return the list if so. Otherwise process the dots as
they should be.
"""
function listify(objs) :: List
    objs_ = collect(objs)
    dots = count(isequal(Dot()), objs_)
    if dots == 0
        objs_
    elseif dots == 1
        if length(objs_) ≤ 2 || objs_[end - 1] !== Dot()
            error("invalid use of .")
        else
            improperlist(objs_[1:end-2], objs_[end])
        end
    elseif dots == 2
        if length(objs_) == 5 && objs_[2] === objs_[4] === Dot()
            [objs_[3], objs_[1], objs_[5]]
        else
            error("invalid use of .")
        end
    else
        error("invalid use of .")
    end
end

"""
    nextobject(io::IO)

Obtain the next Racket object from the given `io` object, wrapped in `Some`, or `nothing` if
there is no more input left.
"""
function nextobject(io::IO) :: Union{Some{<:Union{Dot, SExpression}}, Nothing}
    skipws(io)
    if eof(io)
        return nothing
    end

    c = peek(io, Char)
    if c == ';'
        skipcomment(io)
        nextobject(io)
    elseif c in "([{"
        read(io, Char)
        cl = closer(c)
        objects = readobjectsuntil(io, cl)
        Some(listify(objects))
    elseif c in ")]}"
        error("mismatched superfluous $c")
    elseif c in keys(_READER_MACROS)
        read(io, Char)
        nextobj = nextobject(io)
        if nextobj === nothing
            error("lonely reader macro $c")
        else
            Some(List(_READER_MACROS[c], something(nextobj)))
        end
    elseif c == '"'
        read(io, Char)
        Some(parsestring(io))
    elseif c == '#'
        read(io, Char)
        Some(readhash(io))
    else
        str = readsymbol(io)
        if str == "."
            Some(Dot())
        else
            asnumber = tryparse(Number, str)
            Some(something(asnumber, Symbol(str)))
        end
    end
end

"""
    readobjectsuntil(io::IO, cl::Char)

Read as many Racket objects are are available, then read the closer character.
Return a vector of the read objects.
"""
function readobjectsuntil(io::IO, cl::Char)
    objects = []
    while !eof(io)
        skipws(io)
        c = peek(io, Char)
        if c == cl
            read(io, Char)
            return objects
        else
            obj = nextobject(io)
            if obj === nothing
                break
            else
                push!(objects, something(obj))
            end
        end
    end
    error("unexpected end of file before expected closing $cl character")
end

"""
    readhash(io::IO)

Read the `io` as if a `#` symbol was just seen, and return the read object.
"""
function readhash(io::IO)
    x = read(io, Char)
    if x == 't'
        @syntaxcheck eof(io) || isdelimiter(peek(io, Char)) || begin
            read(io, Char) == 'r'
            read(io, Char) == 'u'
            read(io, Char) == 'e'
        end
        true
    elseif x == 'T'
        @syntaxcheck eof(io) || isdelimiter(peek(io, Char))
        true
    elseif x == 'f'
        @syntaxcheck eof(io) || isdelimiter(peek(io, Char)) || begin
            read(io, Char) == 'a'
            read(io, Char) == 'l'
            read(io, Char) == 's'
            read(io, Char) == 'e'
        end
        false
    elseif x == 'F'
        @syntaxcheck eof(io) || isdelimiter(peek(io, Char))
        false
    elseif x == ':'
        @syntaxcheck !eof(io)
        Keyword(readsymbol(io))
    else
        error("Unsupported syntax: #$x")
    end
end

"""
    skipcomment(io::IO)

Skip all characters until the end of line or end of file.
"""
function skipcomment(io::IO)
    while !eof(io) && !isnewline(read(io, Char)) end
end

"""
    parsestring(io::IO)

Read a string from the given `io` stream, using Racket parsing rules.
"""
function parsestring(io::IO)
    buf = IOBuffer()
    while !eof(io)
        c = read(io, Char)
        if c == '\\'
            x = read(io, Char)
            if x in '0':'7'
                val = x - '0'
                for _ in 1:2
                    if peek(io, Char) in '0':'7'
                        val *= 8
                        val += read(io, Char) - '0'
                    end
                end
                Char(val)
            elseif x in "xuU"
                # TODO
                error("escape sequence \\$x not yet supported")
            elseif x == '\r'
                if !eof(io) && peek(io, Char) == '\n'
                    read(io, Char)
                end
            elseif x == '\n'  # no-op
            elseif x in keys(_ESCAPED)
                write(buf, _ESCAPED[x])
            else
                error("invalid escape sequence \\$x")
            end
        elseif c == '"'
            return String(take!(buf))
        else
            write(buf, c)
        end
    end
    error("unexpected EOF while waiting for terminating \"")
end

"""
    parse(s::AbstractString)

Read the given string `s` as a single s-expression.
"""
function parse(s::AbstractString)
    buf = IOBuffer(s)
    obj = nextobject(buf)
    obj2 = nextobject(buf)
    if obj === nothing
        error("no object to read")
    elseif obj2 === nothing
        something(obj) :: SExpression
    else
        error("extra content after end of expression")
    end
end

"""
    parse(io::IO)

Read a single object from the given `io` stream.
"""
parse(io::IO) = let x = nextobject(io)
    if x === nothing
        error("no object to read")
    else
        something(x) :: SExpression
    end
end

"""
    parsefile(filename::AbstractString)

Parse a file into a single list.
"""
parsefile(filename::AbstractString) = open(parseall, filename)


"""
    parseall(io::IO)
    parseall(s::AbstractString)

Parse all objects from the given stream or string into a single list.
"""
function parseall(io::IO)
    result = []
    while (obj = nextobject(io); obj !== nothing)
        push!(result, something(obj) :: SExpression)
    end
    convert(List, result)
end
parseall(s::AbstractString) = parseall(IOBuffer(s))

end
