# UI页面交互变量，封装在结构体中

@reactive mutable struct PlotPage <: ReactiveModel

    value_plot::R{Int} = 0 # 绑定绘图按钮
    value_rm::R{Int} = 0 # 绑定删除数据按钮

    plot_models::R{Vector{String}} = PLOT_MODEL # 绘图模式选项
    model_choose::R{String} = "CrossPlot" # 绑定选择的模式

    symbol_types::R{Vector{String}} = SYMBOL_TYPE # 散点形状选项
    symbol_choose::R{String} = "circle" # 绑定选择的形状

    range_data::R{RangeData{Int}} = RangeData(1:100)  # 绑定数据选择滑杆

    isSuccess::R{String} = "" # 日志信息记录

    cross_plot_data::R{Vector{PlotData}} = [] # 绑定交会图绘图数据
    cross_plot_layout::R{PlotLayout} = PlotLayout(plot_bgcolor="#fff") # 绑定交会图布局数据

    heatmap_plot_data::R{Vector{PlotData}} = [] # 绑定组合图绘图数据
    heatmap_plot_layout::R{PlotLayout} = PlotLayout(plot_bgcolor="#fff") # 绑定组合图布局数据

end