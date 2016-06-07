using SExpressions
using Base.Test

@test sx"(+ 1 1)" == List(:(+), 1, 1)
@test sx"""
(define (sqr x) (^ x 2))
""" == lispify((
        :define,
        (:sqr, :x),
        (:(^), :x, 2)))

@test sx"""
(html ([lang "en"])
  (head (title "Hello World!"))
  (body (p "This is my first HTSX page")))
""" == lispify((
        :html, ((:lang, "en"),),
        (:head, (:title, "Hello World!")),
        (:body, (:p, "This is my first HTSX page"))))
