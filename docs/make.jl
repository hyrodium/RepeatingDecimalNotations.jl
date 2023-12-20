using Documenter
using DocumenterMermaid
using RepeatingDecimalNotations
using InteractiveUtils

# Setup for doctests in docstrings
DocMeta.setdocmeta!(RepeatingDecimalNotations, :DocTestSetup, :(using RepeatingDecimalNotations))

makedocs(;
    modules = [RepeatingDecimalNotations],
    format = Documenter.HTML(
        ansicolor=true,
        canonical = "https://hyrodium.github.io/RepeatingDecimalNotations.jl/stable/",
        assets = ["assets/favicon.ico", "assets/custom.css"],
        edit_link="main",
        repolink="https://github.com/hyrodium/RepeatingDecimalNotations.jl"
    ),
    pages = [
        "Home" => "index.md",
        "Design" => "design.md",
        "API" => "api.md",
    ],
    repo = "https://github.com/hyrodium/RepeatingDecimalNotations.jl/blob/{commit}{path}#L{line}",
    sitename = "RepeatingDecimalNotations.jl",
    authors = "hyrodium <hyrodium@gmail.com>",
)

deploydocs(
    repo = "github.com/hyrodium/RepeatingDecimalNotations.jl",
    push_preview = true,
    devbranch="main",
)
