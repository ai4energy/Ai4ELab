using Documenter

format = Documenter.HTML(assets = ["assets/css/ai4e.css"])

makedocs(
    sitename="Ai4ELab",
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/quickstart.md",
            "tutorials/webdesign.md",
            "tutorials/styleAndRules.md"
        ],
        "Apps" => [
            "labs/TestLab.md",
            "labs/HeatLab.md",
            "labs/PVLab.md",
            "labs/RobotControlLab.md",
        ]
    ],
    
    format=format,
)

deploydocs(
   repo="https://github.com/ai4energy/Ai4ELab.git";
   push_preview=true
#    target = "../build",
)
