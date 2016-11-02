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
<html lang="en"><head><title>Page 2</title><body><p>This is page 2.</p></body></head></html>"""

@test htsx"""
(#:define (sqr x) (* x x))
(#:define (n^4 x) (* (sqr x) (sqr x)))
(#:define (test x) (string (n^4 x)))
(html ([lang "en"])
  (title (#:template test 10))
  (p "test"))
""" == """
<!DOCTYPE html>
<html lang="en"><title>10000</title><p>test</p></html>"""

@test htsx"""
(#:when (defined? 'x)
  (p "yes 1"))
(#:define (x y) y)
(#:when (defined? 'x)
  (p "yes 2"))
""" == """
<!DOCTYPE html>
<p>yes 2</p>"""

@test Htsx.tohtml("data/file1.lsp") == """
<!DOCTYPE html>
<p>File 2: 100</p><p>File 1: 20</p>"""

end
