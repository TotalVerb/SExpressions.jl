import SExpressions.Parser: readsize, peek

@testset "readsize" begin
    @test readsize(stdin, 0x10) == 1
    @test readsize(stdin, 0x1000) == 2
    @test readsize(stdin, 0x10000000) == 4
    @test readsize(stdin, 0x1000000000000000) == 8
    @test readsize(stdin, 0x10000000000000000000000000000000) == 16
    @test readsize(stdin, Int8(1)) == 1
    @test readsize(stdin, Int16(1)) == 2
    @test readsize(stdin, Int32(1)) == 4
    @test readsize(stdin, Int64(1)) == 8
    @test readsize(stdin, Int128(1)) == 16
    @test readsize(stdin, Float16(0)) == 2
    @test readsize(stdin, 0.0f0) == 4
    @test readsize(stdin, 0.0) == 8
    @test readsize(stdin, 'x') == 1
    @test readsize(stdin, 'α') == 2
    @test readsize(stdin, '←') == 3
    @test readsize(stdin, '🍕') == 4
end

@testset "peek" begin
    buf = IOBuffer("Hello World")
    @test @inferred(peek(buf, UInt8)) == UInt8('H')
    @test @inferred(peek(buf, Char)) == 'H'
    @test @inferred(peek(buf, Char)) == 'H'  # test again
    @test @inferred(read(buf, Char)) == 'H'
    @test @inferred(peek(buf, Char)) == 'e'
    @test length(read(buf, String)) == 10
    @test_throws EOFError peek(buf, UInt8)
    @test_throws EOFError peek(buf, Char)
end
