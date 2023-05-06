using Pkg

##########################################################
using Genie, Stipple, StippleUI
using Genie.Requests, Genie.Renderer

Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

const FILE_PATH1 = "lib/Data_Upload/file.txt"
###########################################################


Pkg.activate(".")
Pkg.instantiate()

include("lib/ui.jl")

const SERVEURL = "http://localhost:8888/Data_Upload"  # 本地运行地址

route("/") do
    # MyApp.MyPage |> init |> ui |> html
    model = MyApp.MyPage |> init
    html(ui(model), context = @__MODULE__)
end

route("/Data_Upload", method = POST) do
    if infilespayload(:txt)
      @info filename(filespayload(:txt))
      @info filespayload(:txt).data
  
      open(FILE_PATH1, "w") do io
        write(FILE_PATH1, filespayload(:txt).data)
      end
    else
      @info "No file uploaded"
      notify(MyApp.MyPage,"No file uploaded")
    end
  end

up(8888,open_browser = true)




