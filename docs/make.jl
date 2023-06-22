using Cerastes
using Documenter

DocMeta.setdocmeta!(Cerastes, :DocTestSetup, :(using Cerastes); recursive=true)

makedocs(;
    modules=[Cerastes],
    authors="Satoshi Terasaki <terasakisatoshi.math@gmail.com> and contributors",
    repo="https://github.com/terasakisatoshi/Cerastes.jl/blob/{commit}{path}#{line}",
    sitename="Cerastes.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://terasakisatoshi.github.io/Cerastes.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/terasakisatoshi/Cerastes.jl",
    devbranch="main",
)
