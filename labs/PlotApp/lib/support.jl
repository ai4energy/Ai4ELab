# 编写绘图数据与绘图布局函数
```
删除文件
```
function remove_data(model::PlotPage)
    files = sort(readdir(FILE_PATH))
    if files == String[]
        model.isSuccess[] = string(now()) * "—— 无数据文件!"
        return []
    end
    for i in readdir(FILE_PATH)
        rm(joinpath(FILE_PATH, i))
        @info "removing: " * joinpath(FILE_PATH, i)
    end
    model.isSuccess[] = string(now()) * "—— 删除$(prod(broadcast(x->" "*x*", ",files)))!"
end

```
解析文件名
```
function get_file_name(name::String)
    posi = getproperty(findfirst(".csv", name), :start)
    return name[1:posi-1]
end


```
读取交会图数据
```
function read_CrossPlot_data(symbol, start, stop, model::PlotPage)
    plot_data = []
    files = sort(readdir(FILE_PATH))
    if files == String[]
        model.isSuccess[] = string(now()) * "—— 无数据文件!"
        return []
    end
    for file in files
        data = CSV.File(joinpath(FILE_PATH, file)) |> Tables.matrix
        len = length(data[1, :])
        row_len = length(data[:, 1])
        data_start = Int(round(row_len * start / 100, digits=0))
        data_start = data_start == 0 ? 1 : data_start
        data_stop = Int(round(row_len * stop / 100, digits=0))
        if isodd(len) # 判定数据是否有效
            model.isSuccess[] = string(now()) * "—— 读取$(prod(broadcast(x->" "*x*", ",files)))错误!"
            return []
        else
            for i in 1:2:len
                push!(plot_data, PlotData(x=data[data_start:data_stop, i],
                    y=data[data_start:data_stop, i+1],
                    plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER,
                    mode="markers",
                    marker=PlotDataMarker(symbol=symbol, size=MARKER_SIZE),
                    name=get_file_name(file) * "_$(Int((i+1)/2))"
                )
                )
            end
        end
    end

    model.isSuccess[] = string(now()) * "—— 读取$(prod(broadcast(x->" "*x*", ",files)))成功!"
    return plot_data
end

```
设定交互图画布布局
```
function read_CrossPlot_Layout()
    names = string.(CSV.getnames(CSV.File(joinpath(FILE_PATH, readdir(FILE_PATH)[1]), limit=1))[1:2])
    return PlotLayout(
        plot_bgcolor=PLOT_BGCOLOR,
        xaxis=[PlotLayoutAxis(xy="x", title=names[1])],
        yaxis=[PlotLayoutAxis(xy="y", title=names[2])]
    )
end

```
生成组合图曲线子图数据
```
function _Heatmap_line(data, data_start, data_stop)
    return PlotData(x=data[data_start:data_stop, 2],
        y=data[data_start:data_stop, 1],
        plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER,
        xaxis="x", yaxis="y"
    )
end

```
生成组合图热图子图数据
```
function _Heatmap_heatmap(data, data_start, data_stop)
    return PlotData(y=data[data_start:data_stop, 1],
        z=[data[i, :] for i in data_start:data_stop],
        plot=StipplePlotly.Charts.PLOT_TYPE_HEATMAP,
        colorscale=MAP_COLORSCALE,
        reversescale=true,
        xaxis="x2", yaxis="y"
    )
end

```
读取组合图绘图数据
```
function read_Heatmap_data(start, stop, model)
    plot_data = []
    files = sort(readdir(FILE_PATH))
    if files == String[]
        model.isSuccess[] = string(now()) * "—— 无数据文件!"
        return []
    elseif length(files) > 2
        model.isSuccess[] = string(now()) * "—— 组合图数据过多！删除数据后重新上传"
        return []
    end
    for i in 1:2
        file = files[i]
        data = CSV.File(joinpath(FILE_PATH, file)) |> Tables.matrix
        row_len = length(data[:, 1])
        data_start = Int(round(row_len * start / 100, digits=0))
        data_start = data_start == 0 ? 1 : data_start
        data_stop = Int(round(row_len * stop / 100, digits=0))
        if i == 1
            push!(plot_data, _Heatmap_line(data, data_start, data_stop))
        else
            push!(plot_data, _Heatmap_heatmap(data, data_start, data_stop))
        end
    end
    model.isSuccess[] = string(now()) * "—— 读取$(prod(broadcast(x->" "*x*", ",files)))成功!"
    return plot_data
end

```
设定组合图画布布局
```
function read_Heatmap_Layout()
    return PlotLayout(
        plot_bgcolor=PLOT_BGCOLOR,
        showlegend=false,
        width=HEATMAPPLOT_WIDTH,
        height=HEATMAPPLOT_HEIGHT,
        xaxis=[
            PlotLayoutAxis(xy="x", index=1, side=HEATMAPPLOT_SIDE, title="GR", domain=HEATMAPPLOT_DOMAIN_LEFT,)
            PlotLayoutAxis(xy="x", index=2, side=HEATMAPPLOT_SIDE, title="VDL", domain=HEATMAPPLOT_DOMAIN_RIGHT, showgrid=false)
        ],
        yaxis=[
            PlotLayoutAxis(xy="y", index=1, autorange="reversed", title="Depth")
            PlotLayoutAxis(xy="y", index=2, autorange="reversed", title="Depth")
        ]
    )
end

```
画图函数
```
function plot_data(model::PlotPage)
    if model.model_choose[] == "CrossPlot"
        model.cross_plot_data[] = read_CrossPlot_data(model.symbol_choose[],
            model.range_data[].range.start,
            model.range_data[].range.stop, model)
        model.cross_plot_layout[] = read_CrossPlot_Layout()
    else
        model.heatmap_plot_data[] = read_Heatmap_data(model.range_data[].range.start,
            model.range_data[].range.stop, model)
        model.heatmap_plot_layout[] = read_Heatmap_Layout()
    end
    nothing
end
