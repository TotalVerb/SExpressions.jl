@testset "Lists" begin

@test filter(iseven, List(1, 2, 3)) == List(2)
@test filter(!iseven, List(1, 2, 3)) == List(1, 3)
@test List(1, 2, 3) ++ List(4, 5, 6) == List(1, 2, 3, 4, 5, 6)
@test append(List(1), List(2), List(3)) == List(1, 2, 3)

@testset "repr" begin
    @test repr(list(1, 2, 3)) == "(1 2 3)"
    @test repr(list(1, true, nothing)) == "(1 #t #<void>)"
end

@testset "map" begin
    @test map(-, List(1, 2, 3)) == List(-1, -2, -3)
    @test map(+, List(1, 2), List(3, 4)) == List(4, 6)
end

@testset "broadcast" begin
    α = List(1, 2, 3)
    β = List(3, 2, 1)
    @test (x -> x^2).(α) == List(1, 4, 9)
    @test α .+ β == List(4, 4, 4)
    @test 3 .* α == List(3, 6, 9)
    @test α .- (α .- 3 .* β) == List(9, 6, 3)

    # This is somewhat hard to get right, because Lists can’t efficiently act like
    # one-dimensional arrays.
    @test_broken α .+ [2, 2, 2] == [3, 4, 5]
end

end
