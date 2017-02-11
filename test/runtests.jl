using SExpressions
using Base.Test
using Base.Iterators

@testset "Parser" begin

@test sx"(+ 1 1)" == List(:(+), 1, 1)
@test sx"""
(define (sqr x) (^ x 2))
""" == lispify((
        :define,
        (:sqr, :x),
        (:(^), :x, 2)))

@test isa(SExpressions.parsefile("data/scheme.jl"), List)

end

@testset "Lists" begin

@test filter(iseven, List(1, 2, 3)) == List(2)
@test filter(!iseven, List(1, 2, 3)) == List(1, 3)
@test List(1, 2, 3) ++ List(4, 5, 6) == List(1, 2, 3, 4, 5, 6)
@test append(List(1), List(2), List(3)) == List(1, 2, 3)

end

include("schemesyntax.jl")
include("htsx.jl")
