# App设计主页面

# 依赖库
using Stipple, StipplePlotly, StippleUI
using CSV, DataFrames, Tables
using Genie.Requests
using Dates


include("types.jl") # 绘图参数

include("init.jl") # 初始化

include("model.jl") # 交互变量结构体

include("support.jl") # 绘图函数

include("ui.jl") # UI布局


# 数据上传
route("/", method=POST) do
    files = Genie.Requests.filespayload()
    for f in files
        write(joinpath(FILE_PATH, f[2].name), f[2].data)
        println()
        @info "Uploading: " * f[2].name
    end
    if length(files) == 0
        @info "No file uploaded"
    end
    return "upload done"
end
