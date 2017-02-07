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

@test htsx"""
(#:execute
  (= x "Hello, World"))
(p (#:var (string x "!")))
""" == """
<!DOCTYPE html>
<p>Hello, World!</p>"""

@test htsx"""
(#:execute
  (= x "Hello, ")
  (= y "World"))
(p (#:var (string x y "!")))
""" == """
<!DOCTYPE html>
<p>Hello, World!</p>"""

@test Htsx.tohtml("data/file1.lsp") == """
<!DOCTYPE html>
<p>File 2: 100</p><p>File 1: 20</p>"""

@test Htsx.tohtml("data/test-dispatch.lsp") == """
<!DOCTYPE html>
<p>12</p>"""

@test htsx"""
(#:define (foo x) 0)
(p (#:var (string (foo 1))))
""" == """
<!DOCTYPE html>
<p>0</p>"""

@test Htsx.tohtml("data/test-markdown.lsp") == """
<!DOCTYPE html>
<div class="markdown"><h1>Some Markdown</h1>
<p><strong>Test</strong>.</p>
</div>"""

@testset "Each" begin
@test htsx"""
(#:each x (List "x" "y" "z")
  `((p ,x)))
""" == """
<!DOCTYPE html>
<p>x</p><p>y</p><p>z</p>"""
end

@testset "Files" begin
@test Htsx.tohtml("data/literal-test.lsp") == """
<!DOCTYPE html>
<script>alert(\"Hello, World!\");
</script>"""
end

@testset "Markdown Render" begin
@test Htsx.tohtml("data/markdown-render.lsp") == """
<!DOCTYPE html>
<p>my <a href="http://example.com">link to</a></p>"""
end

@testset "Object Include" begin
@test Htsx.tohtml("data/object-include.lsp") == """
<!DOCTYPE html>
<p>Hello, World!</p>"""
end

end
