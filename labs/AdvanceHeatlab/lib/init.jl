# 服务设定
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

```
创建文件夹
```
function create_storage_dir(name)
    try
        mkdir(joinpath(@__DIR__, name))
    catch
        @warn "directory already exists"
    end
    return joinpath(@__DIR__, name)
end

# 创建文件夹函数
const FILE_PATH = create_storage_dir("Data_Upload")

# # 数据上传
# route("/Data_Upload", method=POST) do
#     files = Genie.Requests.filespayload()
#     for f in files
#         JSON3.write(joinpath(FILE_PATH, f[2].name), f[2].data)
#         println()
#         @info "Uploading: " * f[2].name
#     end
#     if length(files) == 0
#         @info "No file uploaded"
#     end
#     return "upload done"
# end

# #解析文件名
# function get_file_name(name::String)
#     posi = getproperty(findfirst(".txt", name), :start)
#     return name[1:posi-1]
# end

# # 删除文件
# function remove_data(model::MyApp.MyPage)
#     files = sort(readdir(FILE_PATH))
#     if files == String[]
#         model.isSuccess[] = string(now()) * "—— 无数据文件!"
#         return []
#     end
#     for i in readdir(FILE_PATH)
#         rm(joinpath(FILE_PATH, i))
#         @info "removing: " * joinpath(FILE_PATH, i)
#     end
#     model.isSuccess[] = string(now()) * "—— 删除$(prod(broadcast(x->" "*x*", ",files)))!"
# end