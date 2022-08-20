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