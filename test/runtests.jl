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

@testset "HTSX" begin

@test sx"""
(html ([lang "en"])
  (head (title "Hello World!"))
  (body (p "This is my first HTSX page")))
""" == lispify((
        :html, ((:lang, "en"),),
        (:head, (:title, "Hello World!")),
        (:body, (:p, "This is my first HTSX page"))))

@test htsx"""
(#:define (foo x y) (string (+ x y)))
(html ([lang "en"])
  (head (title "Page " (#:template foo 1 1))
  (body (p "This is page " (#:template foo 1 1) "."))))
""" == """
<!DOCTYPE html>
HTML{String}("")<html lang="en"><head><title>Page 2</title><body><p>This is page 2.</p></body></head></html>"""

end
