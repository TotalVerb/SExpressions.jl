import SExpressions.Parser: readsize, peek

@testset "readsize" begin
    @test readsize(STDIN, 0x10) == 1
    @test readsize(STDIN, 0x1000) == 2
    @test readsize(STDIN, 0x10000000) == 4
    @test readsize(STDIN, 0x1000000000000000) == 8
    @test readsize(STDIN, 0x10000000000000000000000000000000) == 16
    @test readsize(STDIN, Int8(1)) == 1
    @test readsize(STDIN, Int16(1)) == 2
    @test readsize(STDIN, Int32(1)) == 4
    @test readsize(STDIN, Int64(1)) == 8
    @test readsize(STDIN, Int128(1)) == 16
    @test readsize(STDIN, Float16(0)) == 2
    @test readsize(STDIN, 0.0f0) == 4
    @test readsize(STDIN, 0.0) == 8
    @test readsize(STDIN, 'x') == 1
    @test readsize(STDIN, 'α') == 2
    @test readsize(STDIN, '←') == 3
    @test readsize(STDIN, '🍕') == 4
end

@testset "peek" begin
    buf = IOBuffer("Hello World")
    @test @inferred(peek(buf, UInt8)) == UInt8('H')
    @test @inferred(peek(buf, Char)) == 'H'
    @test @inferred(peek(buf, Char)) == 'H'  # test again
    @test @inferred(read(buf, Char)) == 'H'
    @test @inferred(peek(buf, Char)) == 'e'
    @test length(readstring(buf)) == 10
    @test_throws EOFError peek(buf, UInt8)
    @test_throws EOFError peek(buf, Char)
end
