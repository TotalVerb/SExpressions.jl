using Documenter
using SExpressions

makedocs(
    format = Documenter.HTML(analytics="UA-68884109-1"),
    sitename = "SExpressions.jl",
    authors = "Fengyang Wang",
    pages = [
        "index.md"
    ]
)

deploydocs(
    repo   = "github.com/TotalVerb/SExpressions.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing,
)
