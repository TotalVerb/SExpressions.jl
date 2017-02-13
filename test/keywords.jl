@testset "Keywords" begin

using SExpressions.Keywords

@test Keyword("test") == Keyword("test")
@test Keyword("test") ≠ Keyword("Test")

x = Dict(Keyword("test") => "hello",
         Keyword("test2") => "world",
         Keyword("test3") => "!")

@test x[Keyword("test")] == "hello"
x[Keyword("test")] = "modified"
@test x[Keyword("test")] == "modified"

end
