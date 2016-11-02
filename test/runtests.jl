using SExpressions
using Base.Test

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

@testset "Julia" begin

@test SExpressions.SimpleJulia.tojulia(sx"(+ 1 1)") == :(1 + 1)
@test SExpressions.SimpleJulia.tojulia(sx"""
  (if x y z)
""") == :(x ? y : z)

evaluate(α) = eval(SExpressions.SimpleJulia.tojulia(α))

@test evaluate(sx"'x") == :x
@test evaluate(sx"`(+ 1 1)") == List(:+, 1, 1)
@test evaluate(sx"""
(begin
  (= x 2)
  `(+ ,x x))
""") == List(:+, 2, :x)

@test evaluate(sx"""
(begin
  (define (foo (:: x Integer)) 1)
  (define (foo (:: x String)) 2)
  (string (foo 1) (foo "x")))
""") == "12"

end

include("htsx.jl")
