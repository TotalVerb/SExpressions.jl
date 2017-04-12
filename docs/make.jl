using Documenter
using SExpressions

makedocs(
    format = :html,
    sitename = "SExpressions.jl",
    authors = "Fengyang Wang",
    analytics = "UA-68884109-1",
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
