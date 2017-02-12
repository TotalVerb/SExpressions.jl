# A mini purely functional lisp with continuations
# warning: no garbage collection yet

# nowhere near complete; enable when done

#=
module MiniLisp

using ..Lists

abstract type Continuation; end

const BUILTINS = List(
    List(:(+), +),
    List(:(-), -),
    List(:cons, Cons),
    List(:car, car),
    List(:cdr, cdr))

function compute(::Nil, ::List, ::Continuation) = error("Cannot evaluate nil")

# π: program
# ɛ: environment
# k: continuation
function compute(π::Cons, ɛ::List, k::Continuation)
    if car(π) == :
    end
end

end
=#
