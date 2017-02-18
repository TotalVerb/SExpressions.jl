@testset "Parser" begin

@test sx"(+ 1 1)" == List(:(+), 1, 1)
@test sx"""
(define (sqr x) (^ x 2))
""" == lispify((
        :define,
        (:sqr, :x),
        (:(^), :x, 2)))

@test SExpressions.parsefile("data/scheme.scm") isa List

@test sx"-1" == -1
@test sx"+1000" == 1000
@test sx"-15/5" == -3
@test sx"+13/17" == 13//17

@test sx"(+ 1/2 1/3)" == List(:(+), 1//2, 1//3)

@test_throws ErrorException SExpressions.parses("(+ 1 1")
@test_throws ErrorException SExpressions.parses("(+ 1 1]")
@test_throws ErrorException SExpressions.parses("(+ 1 1))")
@test_throws ErrorException SExpressions.parses("(+ 1 1;)")
@test sx"1;" == 1

end