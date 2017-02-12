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

@test SExpressions.parsefile("data/scheme.scm") isa List

@test_throws ErrorException SExpressions.parses("(+ 1 1")
@test_throws ErrorException SExpressions.parses("(+ 1 1]")
@test_throws ErrorException SExpressions.parses("(+ 1 1))")
@test_throws ErrorException SExpressions.parses("(+ 1 1;)")
@test sx"1;" == 1

end

@testset "Lists" begin

@test filter(iseven, List(1, 2, 3)) == List(2)
@test filter(!iseven, List(1, 2, 3)) == List(1, 3)
@test List(1, 2, 3) ++ List(4, 5, 6) == List(1, 2, 3, 4, 5, 6)
@test append(List(1), List(2), List(3)) == List(1, 2, 3)

@testset "repr" begin
    @test repr(list(1, 2, 3)) == "(1 2 3)"
    @test repr(list(1, true, nothing)) == "(1 #t #<void>)"
end

end

include("htsx.jl")
