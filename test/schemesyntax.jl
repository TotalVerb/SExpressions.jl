@testset "Scheme Syntax" begin

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

@test evaluate(sx"((. Base +) 1 2)") == 3

@test evaluate(sx"(and #t #t)")
@test !evaluate(sx"(and #t #f)")
@test !evaluate(sx"(and #f #f)")
@test evaluate(sx"(or #t #t)")
@test evaluate(sx"(or #t #f)")
@test !evaluate(sx"(or #f #f)")

@test evaluate(sx"(ref (List 1 2 3) 2)") == 2

@testset "λ" begin
    @test evaluate(sx"((λ (x) (* x x)) 10)") == 100
    @test evaluate(sx"((λ (x y) (* x y)) 10 20)") == 200
end

@testset "let" begin
    @test evaluate(sx"(let ([x 1]) x)") == 1
    @test evaluate(sx"(let ([x 1] [y 2]) (+ x y))") == 3
    @test evaluate(sx"(let ([x 1] [y (+ 1 1)]) (+ x y))") == 3
end

@testset "." begin
    @test evaluate(sx"(. Base Markdown)") === Base.Markdown
    @test evaluate(sx"(. Base Markdown MD)") === Base.Markdown.MD
end

@testset "define" begin
    @test evaluate(sx"(begin (define x 1) x)") == 1
    @test evaluate(sx"(begin (define x 1) (+ x x))") == 2
    @test evaluate(sx"""
(begin
  (define x 1)
  (define y 2)
  (+ x y))
""") == 3

    @test evaluate(sx"(define x 1)") == nothing
    @test evaluate(sx"(define (f x) 1)") == nothing
    @test evaluate(sx"(begin (define (f x) 1) (f 0))") == 1
    @test evaluate(sx"(begin (define (f x) x) (f 0))") == 0
end

end
