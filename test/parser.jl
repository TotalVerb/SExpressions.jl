@testset "Parser" begin

sx = SExpressions.parse

@testset "numbers" begin
    @test sx("-1") == -1
    @test sx("+1000") == 1000
    @test sx("-15/5") == -3
    @test sx("+13/17") == 13//17
    @test sx("-1/2") == -1//2
    @test sx("-1/2+3i") == -1//2+3im
    @test sx("3+4/3i") == 3+4im//3
    @test sx("3-2i") == 3-2im
end

@testset "booleans" begin
    @test sx("#t")
    @test sx("#true")
    @test sx("#T")
    @test !sx("#f")
    @test !sx("#false")
    @test !sx("#F")
end

@testset "arithmetic" begin
    @test sx("(+ 1 1)") == List(:(+), 1, 1)
    @test sx("(+ 1/2 1/3)") == List(:(+), 1//2, 1//3)
    @test sx("""
    (define (sqr x) (^ x 2))
    """) == lispify((
            :define,
            (:sqr, :x),
            (:(^), :x, 2)))
end

@testset "invalid syntax" begin
    @test_throws ErrorException SExpressions.parseall("(+ 1 1")
    @test_throws ErrorException SExpressions.parseall("(+ 1 1]")
    @test_throws ErrorException SExpressions.parseall("(+ 1 1))")
    @test_throws ErrorException SExpressions.parseall("(+ 1 1;)")
end

@testset "comment" begin
    @test sx("1;") == 1
    @test sx(";
             x") == :x
    @test sx(";
    ;
    ;
    4;2
    ") == 4
end

@testset "strings" begin
    @test sx("\"x\"") == "x"
    @test sx("\"x\\n\"") == "x\n"
    @test sx("""\"
    x\\
    y\\\\
    z\"""") == "\nxy\\\nz"
end

@testset "symbols" begin
    @test sx("foo") == :foo
    @test_broken sx("|x|") == :x
    @test_broken sx("| |") == Symbol(" ")
end

@testset "lists" begin
    @test sx("(1 2 3)") == List(1, 2, 3)
    @test sx("(1 . 2)") == Cons(1, 2)
    @test sx("(1 . (2))") == List(1, 2)
    @test sx("(1 . + . 2)") == List(:+, 1, 2)
    @test sx("(1 2 . 3)") == Cons(1, Cons(2, 3))
    @test_throws ErrorException sx("(.)")
    @test_throws ErrorException sx("(. x)")
    @test_throws ErrorException sx("(1 . 2 3)")
    @test_throws ErrorException sx("(1 . 2 . 3 . 4)")
end

@testset "reader macros" begin
    @test sx("'x") == List(:quote, :x)
    @test sx("`(+ 1 2)") == List(:quasiquote, List(:(+), 1, 2))
    @test sx("`(+ ,x 2)") == List(:quasiquote,
                                  List(:(+), List(:unquote, :x), 2))
    @test_broken sx("`(+ ,@xs 2)") ==
        lispify((:quasiquote,
                 (:(+),
                  (Symbol("unquote-splicing"), :x),
                  2)))
end

@testset "file" begin
    @test SExpressions.parsefile("data/scheme.scm") isa List
end

@testset "macro" begin
    # Wrap in `@eval` to capture failures at test time rather than load time.
    @test @eval(sx"1")   == 1
    @test @eval(sx"foo") == :foo
end

end
