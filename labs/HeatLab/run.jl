for file in readdir("./lib")
    include("lib/" * file)
end

route("/") do
    MyApp.htmlfile
end

try
    if isDeploy
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
    up()
end


