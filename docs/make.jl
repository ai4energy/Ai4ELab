using Documenter, DemoCards, JSON

apps, postprocess_cb, apps_assets = makedemos("apps")
assets = collect(filter(x -> !isnothing(x), Set([apps_assets])))
push!(assets, "assets/css/ai4e.css")
format = Documenter.HTML(assets=assets)
makedocs(
    sitename="Ai4ELab",
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/quickstart.md",
            "tutorials/webdesign.md",
            "tutorials/styleAndRules.md"
        ],
        apps,
    ], format=format,
)

postprocess_cb()

deploydocs(
    repo="https://github.com/ai4energy/Ai4ELab.git";
    #    push_preview=true
    #    target = "../build",
)
