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
(remark
  (define (foo-bar x y) (string (+ x y))))
(html ([lang "en"])
  (head (title "Page " (#:template foo-bar 1 1))
  (body (p "This is page " (#:template foo-bar 1 1) "."))))
""" == """
<!DOCTYPE html>
<html lang="en"><head><title>Page 2</title><body><p>This is page 2.</p></body></head></html>"""

@test htsx"""
(remark
  (define (sqr x) (* x x))
  (define (n^4 x) (* (sqr x) (sqr x)))
  (define (test x) (string (n^4 x))))
(html ([lang "en"])
  (title (#:template test 10))
  (p "test"))
""" == """
<!DOCTYPE html>
<html lang="en"><title>10000</title><p>test</p></html>"""

@testset "When" begin
@test htsx"""
(#:when (defined? 'x)
  (p "yes 1"))
(remark (define (x y) y))
(#:when (defined? 'x)
  (p "yes 2"))
""" == """
<!DOCTYPE html>
<p>yes 2</p>"""

@test htsx"""
(p (include (when (< 1 2) (define x 1) (+ x x)) #:object))
""" == """
<!DOCTYPE html>
<p>2</p>"""

@test htsx"""
(p (include (when (> 1 2) "Hello") #:object))
""" == """
<!DOCTYPE html>
<p></p>"""
end

@testset "Remark" begin
@test htsx"""
(remark
  (define x "Hello, World"))
(p (remark (string x "!")))
""" == """
<!DOCTYPE html>
<p>Hello, World!</p>"""

@test htsx"""
(remark
  (define x "Hello, ")
  (define y "World"))
(p (remark (string x y "!")))
""" == """
<!DOCTYPE html>
<p>Hello, World!</p>"""

@test htsx"""
(remark (define (foo x) 0))
(p (remark (foo 1)))
""" == """
<!DOCTYPE html>
<p>0</p>"""
end

@testset "Remarks" begin
@test htsx"""
(remarks
 (define n 7000000000)
 `((p "Hello World")
   (p "All " ,n " are welcome!")))
""" == """
<!DOCTYPE html>
<p>Hello World</p><p>All 7000000000 are welcome!</p>"""
end

@test Htsx.tohtml("data/file1.lsp") == """
<!DOCTYPE html>
<p>File 2: 100</p><p>File 1: 20</p>"""

@test Htsx.tohtml("data/test-dispatch.lsp") == """
<!DOCTYPE html>
<p>12</p>"""

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
