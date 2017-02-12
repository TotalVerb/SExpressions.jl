using SExpressions.Lists
using SExpressions.RacketExtensions
using SExpressions.R5RS

@testset "Scheme Syntax" begin

evaluate(α) = eval(SExpressions.SimpleJulia.tojulia(α))

@testset "Calls" begin
    @test SExpressions.SimpleJulia.tojulia(sx"(+ 1 1)") == :(1 + 1)
    @test evaluate(sx"(+ 1 1)") == 2
    @test evaluate(sx"(void)") === nothing
    @test evaluate(sx"(void 1 2)") === nothing
    @test evaluate(sx"(void (* 1 3))") === nothing
end

@testset "if" begin
    @test SExpressions.SimpleJulia.tojulia(sx"""
      (if x y z)
    """) == :(x ? y : z)
end

@testset "quote" begin
    @test evaluate(sx"'x") == :x
    @test evaluate(sx"`(+ 1 1)") == List(:+, 1, 1)
end

@testset "set!" begin
    @test evaluate(sx"""
    (begin
      (define x 1)
      (set! x 2)
      `(+ ,x x))
    """) == List(:+, 2, :x)
end

@testset "Julia" begin
    @test evaluate(sx"""
    (begin
      (define (foo (:: x Integer)) 1)
      (define (foo (:: x String)) 2)
      (string (foo 1) (foo "x")))
    """) == "12"

    @test evaluate(sx"((. Base +) 1 2)") == 3
end

for (sym, fn) in [[:and, &], [:or, |]]
    @testset "$sym" begin
        for a in [false, true]
            for b in [false, true]
                @test evaluate(list(sym, a, b)) == fn(a, b)
            end
        end
    end
end

@testset "not" begin
    @test evaluate(sx"(not #f)")
    @test !evaluate(sx"(not #t)")
    @test !evaluate(sx"(not 1)")
end

@testset "boolean?" begin
    @test evaluate(sx"(boolean? #t)")
    @test evaluate(sx"(boolean? #f)")
    @test !evaluate(sx"(boolean? 10)")
end

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

@testset "when" begin
    @test evaluate(sx"(when #t (+ 1 1))") == 2
    @test evaluate(sx"(when #f (+ 1 1))") == nothing
    @test evaluate(sx"(when #t (cons 'x nil))") == cons(:x, nil)
    @test evaluate(sx"(when #f (cons 'x nil))") == nothing
    @test evaluate(sx"(when (== 1 2) (+ 1 1))") == nothing
    @test evaluate(sx"(when (< 1 2) (+ 1 1))") == 2
end
@testset "unless" begin
    @test evaluate(sx"(let ([x #f]) (unless x 1))") == 1
    @test evaluate(sx"(let ([x #t]) (unless x 1))") == nothing
end

end
