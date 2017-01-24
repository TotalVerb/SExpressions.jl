module Htsx

using ..Parser
using ..Lists
using ..Keywords
using ..SimpleJulia
using Compat
using Hiccup
using FunctionalCollections

include("Htsx/markdown-htsx.jl")
include("Htsx/stdlib.jl")

function makeenv(ass=Dict(), modules=[])
    Env = Module(gensym(:Env))
    eval(Env, quote
        using Compat
        using Base.Iterators
        using SExpressions.Lists
        using SExpressions.Keywords
        using SExpressions.SimpleJulia
        import SExpressions.Htsx.StdLib
        using Hiccup
    end)
    for (k, v) in ass
        eval(Env, :($k = $v))
    end
    for touse in modules
        eval(Env, :(const $(module_name(touse)) = $touse))
        eval(Env, :(using .$(module_name(touse))))
    end
    Env
end

immutable HtsxState
    env::Module
    file::String
end
getvar(s::HtsxState, v::Symbol) = getfield(s.env, v)
evaluate!(s::HtsxState, ex) = eval(s.env, tojulia(ex))
relativeto(s::HtsxState, f) = joinpath(dirname(s.file), f)

setindex(x, y, z) = assoc(x, z, y)

"""
Return `true` if `α` is a list, and each element in `α` is a list.
"""
islisty(α::List) = all(β -> isa(β, List), α)
islisty(_) = false

"""
Monad-ish: thread second argument through successive calls of `f` to elements
of `xs`.
"""
function acc2(f, xs, acc)
    res = []
    for x in xs
        r, acc = f(x, acc)
        push!(res, r)
    end
    res, acc
end

function gethiccupnode(head, ρ, state)
    error("Invalid HTSX head: $head")
end

function gethiccupnode(head::Symbol, ρ, state)
    if isnil(ρ)
        Node(head, Dict(), []), state
    else
        if islisty(car(ρ))  # is a list of attrs
            attrs = Dict(car(β) => cadr(β) for β in car(ρ))
            content, state = acc2(tohiccup, cdr(ρ), state)
        else  # is just another body element
            attrs = Dict()
            content, state = acc2(tohiccup, ρ, state)
        end
        Node(head, attrs, collect(content)), state
    end
end

function gethiccupnode(head::Keyword, ρ, state)
    if head == Keyword("template")
        tohiccup(evaluate!(state, :($(car(ρ))($(cdr(ρ)...)))), state)
    elseif head == Keyword("var")
        evaluate!(state, car(ρ)), state
    elseif head == Keyword("execute")
        evaluate!(state, car(ρ))
        html"", state
    elseif head == Keyword("when")
        cond = car(ρ)
        if evaluate!(state, cond)
            res, state = tohiccups(cdr(ρ), state)
            HTML(sprint(show_html, res)), state
        else
            html"", state
        end
    elseif head == Keyword("include")
        url = evaluate!(state, car(ρ))
        file = relativeto(state, url)
        α = Parser.parsefile(file)
        res, state = tohiccups(α, state)
        HTML(sprint(show_html, res)), state
    elseif head == Keyword("file")
        url = evaluate!(state, car(ρ))
        file = relativeto(state, url)
        readstring(file), state
    elseif head == Keyword("each")
        var, array, code = ρ
        doms = eval(state.env, quote
            map($(tojulia(array))) do $var
                $(tojulia(code))
            end
        end)
        f = IOBuffer()
        for dom in doms
            res, state = tohiccups(dom, state)
            show_html(f, res)
        end
        HTML(String(take!(f))), state
    elseif head == Keyword("markdown")
        url = evaluate!(state, car(ρ))
        file = relativeto(state, url)
        data = stringmime("text/html", Base.Markdown.parse(readstring(file)))
        HTML(data), state
    elseif head == Keyword("define")
        fn = tojulia(car(ρ))
        if !Meta.isexpr(fn, :call)
            error("wrong define syntax")
        end
        newfn = eval(state.env,
            Expr(:function, Expr(:call, fn.args...),
            tojulia(cadr(ρ))))
        html"", state  # nothing value
    else
        error("Unsupported HTSX keyword $head")
    end
end

function tohiccup(α::List, state)
    len = length(α)
    if len < 1
        error("Empty list not allowed here")
    else
        head = car(α)
        gethiccupnode(head, cdr(α), state)
    end
end

tohiccup(s::String, state) = s, state
tohiccup(s::AbstractString, state) = tohiccup(String(s), state)
tohiccup(i::BigInt, state) = string(i), state

tohiccup(x, state) = error("Can’t serialize $(repr(x))")

typealias ListOrArray Union{List, Array}

function tohiccups(α::ListOrArray, state::HtsxState)
    parts = []
    for β in α
        res, state = tohiccup(β, state)
        push!(parts, res)
    end
    parts, state
end

function show_html(io::IO, ashiccup)
    join(io, (stringmime("text/html", p) for p in ashiccup))
end

function tohtml(io::IO, α::List, tmpls=PersistentHashMap{Symbol,Any}();
                file=joinpath(pwd(), "_implicit.htsx"),
                modules=[])
    println(io, "<!DOCTYPE html>")
    state = HtsxState(makeenv(tmpls, modules), file)
    ashiccup, _ = tohiccups(α, state)
    show_html(io, ashiccup)
end

function tohtml(io::IO, f::AbstractString,
                tmpls=PersistentHashMap{Symbol,Any}();
                modules=[])
    tohtml(io, Parser.parsefile(f), tmpls; file=abspath(f), modules=modules)
end

tohtml(α::Union{List,AbstractString}, tmpls=PersistentHashMap{Symbol,Any}()) =
    sprint(tohtml, α, tmpls)

end
