using Documenter

format = Documenter.HTML(assets = ["assets/css/ai4e.css"])

makedocs(
    sitename="Ai4ELab",
    pages=[
        "Home" => "index.md"
    ],
    format=format,
)

deploydocs(
   repo="https://github.com/ai4energy/Ai4EDocs.git";
   push_preview=true
#    target = "../build",
)
