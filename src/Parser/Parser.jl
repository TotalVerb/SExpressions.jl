# Simple recursive descent parser

module Parser

using Base.Iterators
using ..Lists
using ..Keywords

include("numeric.jl")

export parse

const _PUNCT = ('(', ')', '[', ']', '{', '}', '"', ';')
ispunct(c) = c ∈ _PUNCT

const _NEWLINE = (
        '\u000D', '\u000A', '\u0085', '\u000B', '\u000C', '\u2028', '\u2029')
isnewline(c) = c ∈ _NEWLINE

const _CLOSE = Dict('(' => ')', '[' => ']', '{' => '}', '"' => '"')
close(c) = _CLOSE[c]

const _READER_MACROS = Dict(
    '\'' => :quote,
    '`' => :quasiquote,
    ',' => :unquote)

"""
Skip all whitespace characters starting at the given index of the given
`AbstractString`.
"""
function skipws(s::AbstractString, i)
    while i ≤ endof(s) && isspace(s[i])
        i = nextind(s, i)
    end
    i
end

"""
Skip all characters until the next newline character.
"""
function skipline(s::AbstractString, i)
    while i ≤ endof(s) && !isnewline(s[i])
        i = nextind(s, i)
    end
    i
end

"""
Parse a `Symbol` or number or `Keyword` or `Bool` at the given index.
"""
function parse(::Type{Symbol}, s::AbstractString, i)
    i = skipws(s, i)
    buf = Char[]
    while i ≤ endof(s) && !isspace(s[i]) && !ispunct(s[i])
        push!(buf, s[i])
        i = nextind(s, i)
    end
    str = join(buf, "")

    asnumber = tryparse(Number, str)
    i, if !isnull(asnumber)
        get(asnumber)
    elseif str == "#t"
        true
    elseif str == "#f"
        false
    elseif length(str) ≥ 2 && startswith(str, "#:")
        Keyword(String(collect(drop(str, 2))))
    else
        Symbol(str)
    end
end

"""
Parse a `String` at the given index.
"""
function parse(::Type{String}, s::AbstractString, i, c)
    buf = Char[]
    while i ≤ endof(s) && s[i] ≠ c
        if s[i] == '\\'  # at least one extra character to parse
            push!(buf, s[i])
            i = nextind(s, i)
            push!(buf, s[i])
        else
            push!(buf, s[i])
        end
        i = nextind(s, i)
    end
    nextind(s, i), unescape_string(join(buf, ""))
end

"""
Parse a list at the given index.
"""
function parse(::Type{List}, s::AbstractString, i, c)
    i = skipws(s, i)
    if i > endof(s)
        error("Missing $c at end of file.")
    elseif s[i] == c
        nextind(s, i), nil
    elseif s[i] in (')', ']', '}')
        error("Mismatched parentheses; expected $c found $(s[i]).")
    else
        i, ele = parse(s, i)
        i = skipws(s, i)
        i, rst = parse(List, s, i, c)
        i = skipws(s, i)
        i, Cons(ele, rst)
    end
end

function tryparse(s::AbstractString, i)
    i = skipws(s, i)
    if i > endof(s)
        i, Nullable{Any}()
    elseif s[i] in ('(', '[', '{')
        i, res = parse(List, s, nextind(s, i), close(s[i]))
        i, Nullable{Any}(res)
    elseif s[i] in (')', ']', '}')
        error("Unexpected extraneous $(s[i]).")
    elseif s[i] == '"'
        i, res = parse(String, s, nextind(s, i), close(s[i]))
        i, Nullable{Any}(res)
    elseif s[i] == ';'
        i = skipline(s, i)
        tryparse(s, i)
    elseif haskey(_READER_MACROS, s[i])
        c = s[i]
        i, ele = parse(s, nextind(s, i))
        i, Nullable{Any}(List(_READER_MACROS[c], ele))
    else
        i, res = parse(Symbol, s, i)
        i, Nullable{Any}(res)
    end
end

"""
Parse an s-expression at the given index of the given AbstractString.
"""
function parse(s::AbstractString, i)
    i, res = tryparse(s, i)
    if isnull(res)
        error("Unexpected end of file.")
    else
        i, get(res)
    end
end
parse(s::AbstractString) = parse(s, 1)[2]

"""
Parse an entire string into a single list.
"""
function parses(s::AbstractString, i=1)
    i, res = tryparse(s, i)
    if isnull(res)
        nil
    else
        Cons(get(res), parses(s, i))
    end
end

"""
Parse a file into a single list.
"""
parsefile(filename::AbstractString) = parses(readstring(filename))

end