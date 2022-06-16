using Pkg
Pkg.activate(".")
Pkg.instantiate()

try
    if isDeploy

        include("lib/MyApp.jl")

        route("/") do
            MyApp.MyPage |> init |> ui |> html
        end

        function force_compile()
            sleep(5)
            for (name, r) in Router.named_routes()
                Genie.Requests.HTTP.request(r.method, "http://localhost:8000" * tolink(name))
            end
        end
        @async force_compile()

        up(8000, "0.0.0.0", async=false)
    end
catch e
    using Revise

    includet("lib/MyApp.jl")

    route("/") do
        MyApp.MyPage |> init |> ui |> html
    end

    up()
end


