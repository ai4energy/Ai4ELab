using Pkg
ENV["JULIA_PKG_SERVER"] = "https://mirrors.tuna.tsinghua.edu.cn/julia/" # 清华镜像服务
Pkg.activate(".") # 将环境切换到项目文件夹
Pkg.instantiate() # 安装依赖包

const SERVEURL = "https://ai4energy-plotlab.herokuapp.com/"  # 云服务器地址

# const SERVEURL = "http://localhost:8000/"  # 本地运行地址

try # 服务端运行
    if isDeploy
        include("lib/PlotApp.jl")
        route("/") do
            PlotPage |> init |> ui |> html
        end
        function force_compile()
            sleep(30)
            for (name, r) in Router.named_routes()
                Genie.Requests.HTTP.request(r.method, SERVEURL * tolink(name))
            end
        end
        @async force_compile()
        up(8000, "0.0.0.0", async=false) # 服务端不开异步
    end

catch e # 本地运行
    using Revise

    includet("lib/PlotApp.jl")

    route("/") do
        PlotPage |> init |> ui |> html
    end

    up(open_browser=true,async=false)
end


