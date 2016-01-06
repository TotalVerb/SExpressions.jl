module SExpressions

isnewline(c::Char) = c ∈ Set([
    '\u000A', '\u000B', '\u000C',
    '\u000D', '\u000D', '\u000A',
    '\u0085', '\u2028', '\u2029'])

import Base: done, eltype, endof, getindex,
    isnumber, length, next, parse, push!, show, start

abstract AbstractSExpr
typealias SExpr Union{Bool, Integer, UTF8String, AbstractSExpr}

type SExprID <: AbstractSExpr
    id::UTF8String
end

value(id::SExprID) = id.id
Base. ==(s::SExprID, t::SExprID) = s.id == t.id

type SExprVector <: AbstractSExpr
    sexprs::Vector{SExpr}
end
Base. ==(s::SExprVector, t::SExprVector) = s.sexprs == t.sexprs

start(sx::SExprVector) = 1
done(sx::SExprVector, istate::Int) = istate > endof(sx.sexprs)
next(sx::SExprVector, istate::Int) = sx.sexprs[istate], istate + 1
length(sx::SExprVector) = length(sx.sexprs)
eltype(::Type{SExprVector}) = SExpr
endof(sx::SExprVector) = endof(sx.sexprs)
getindex(sx::SExprVector, i) = sx.sexprs[i]

function show(io::IO, sx::SExprID)
    write(io, sx.id)
end

function show(io::IO, sx::SExprVector)
    if length(sx.sexprs) == 0
        write(io, "()")
    else
        write(io, '(')
        first = true
        show(io, sx.sexprs[1])
        for ssx in sx.sexprs[2:end]
            write(io, ' ')
            show(io, ssx)
        end
        write(io, ')')
    end
end

type ParserState
    state::Symbol
    data::Vector{Char}
    parts::Vector{SExpr}
    quotes::UInt
    comment::Bool
end
ParserState() = ParserState(:seek, Char[], SExpr[], 0, false)
function addquote!(so::ParserState)
    so.quotes += 1
end
function unquote!(so::ParserState)
    so.quotes -= 1
end
quotes(so::ParserState) = so.quotes
comment!(so::ParserState) = (so.comment = true)
uncomment!(so::ParserState) = (so.comment = false)
comment(so::ParserState) = so.comment
function state!(so::ParserState, s::Symbol)
    so.state = s
end
state(so::ParserState) = so.state
function cleardata!(so::ParserState, data::Vector{Char}=Char[])
    so.data = data
end
function data!(so::ParserState, app::Char)
    push!(so.data, app)
end
data(so::ParserState) = so.data
function push!(so::ParserState, sexpr::SExpr)
    fsx = sexpr
    while quotes(so) > 0
        unquote!(so)
        fsx = SExprVector([SExprID("quote"), fsx])
    end
    push!(so.parts, fsx)
end
sexpr(so::ParserState) = SExprVector(so.parts)

opens = Set(['(', '[', '{'])
closes = Set([')', ']', '}'])
reserved = opens ∪ closes

function specialize(data::Vector{Char})
    data = UTF8String(data)
    if data == "#f" || data == "#false"
        false
    elseif data == "#t" || data == "#true"
        true
    elseif all(x -> x ∈ "0123456789", data)
        parse(data)
    else
        SExprID(data)
    end
end

function munch!(so::ParserState, c::Char)
    # println("State: $(state(so)); Character: $c")
    if comment(so)
        if isnewline(c)
            uncomment!(so)
            false
        else
            true
        end
    elseif c == ';'
        comment!(so)
    elseif state(so) == :seek
        if c == '"'
            state!(so, :string)
            cleardata!(so)
            true  # continue?
        elseif c == '\''
            addquote!(so)
            true
        elseif c ∈ opens
            state!(so, :subexpr)
            true
        elseif c ∈ closes
            state!(so, :done)
            true
        elseif !isspace(c)
            state!(so, :id)
            cleardata!(so)
            false
        else
            true
        end
    elseif state(so) == :string
        if c == '"'
            state!(so, :seek)
            push!(so, data(so) |> UTF8String)
            true
        else
            data!(so, c)
            true
        end
    elseif state(so) == :id
        if isspace(c) || c ∈ reserved
            state!(so, :seek)
            push!(so, specialize(data(so)))
            false
        else
            data!(so, c)
            true
        end
    else
        error("can't parse")
    end
end

function getsexpr(iobj, istate)
    pstate = ParserState()

    while true
        if done(iobj, istate)
            return istate, sexpr(pstate)
        end

        if state(pstate) == :subexpr
            istate, sx = getsexpr(iobj, istate)
            push!(pstate, sx)
            state!(pstate, :seek)
        elseif state(pstate) == :done
            return istate, sexpr(pstate)
        end

        c, nstate = next(iobj, istate)
        if munch!(pstate, c)
            istate = nstate
        end
    end
end

function parse(::Type{SExpr}, program::AbstractString)
    last(getsexpr(program * ")", start(program)))
end

macro sexpr_str(p)
    parse(SExpr, p)
end

export SExpr, SExprVector, SExprID, value, @sexpr_str

end  # module SExpressions
