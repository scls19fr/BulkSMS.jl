using Documenter
using BulkSMS


makedocs(
    format = :html,
    sitename = "BulkSMS.jl",
    pages = [
        "index.md",
    ]
)

deploydocs(
    repo = "github.com/scls19fr/BulkSMS.jl.git",
    julia  = "0.7",
    latest = "master",
    target = "build",
    deps = nothing,  # we use the `format = :html`, without `mkdocs`
    make = nothing,  # we use the `format = :html`, without `mkdocs`
)
