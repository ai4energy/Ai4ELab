module MyApp
using Stipple,StipplePlotly, StippleUI, DataFrames
include("solver.jl")
@reactive mutable struct MyPage <: ReactiveModel
    #1.初始化表格
    tableData::R{DataTable} = DataTable(DataFrame(zeros(10,10), ["$i" for i in 1:10]))
    #1.1.设置表格的显示方式(一页10行)
    credit_data_pagination::DataTablePagination = DataTablePagination(rows_per_page=10)

    #2.交互所必要变量
    value::R{Int} = 0
    click::R{Int} = 0
    isloading::R{Bool} = false
    # value_rm::R{Int} = 0

    #4.初始化温度场
    u0::R{Vector{Float64}} = []

    #3.温度边界条件
    #3.2默认边界
    innerheat::R{String} = "0"
    #3.5求解的时间域(0~timefield)
    timefield::R{Float64} = 100

    selections::R{Vector{String}} = ["第一类边界条件(温度/°C)", "第二类边界条件(热流密度/(W/m^2))", "第三类边界条件(对流换热)"]
    selection1::R{String} = "第一类边界条件(温度/°C)"
    selection2::R{String} = "第一类边界条件(温度/°C)"
    selection3::R{String} = "第一类边界条件(温度/°C)"
    selection4::R{String} = "第一类边界条件(温度/°C)"
    showinput1::R{Bool} = false
    showinput2::R{Bool} = false
    showinput3::R{Bool} = false
    showinput4::R{Bool} = false
    funcstr1::R{String} = "0"
    funcstr2::R{String} = "0"
    funcstr3::R{String} = "0"
    funcstr4::R{String} = "0"

    #1.1.4对流换热系数
    h::Vector{Float64} = zeros(11)
    density::R{String} = "1.0"
    a::R{String} = "1.27E-5"
    c::R{String} = "1.0"
    n::R{String} = "10.0"
    m::R{String} = "10.0"
    Lx::R{String} = "1.0"
    Ly::R{String} = "1.0"
    h1::R{String} = "0.0"
    h2::R{String} = "0.0"
    h3::R{String} = "0.0"
    h4::R{String} = "0.0"
    #4.绘图
    #4.1初始化图片
    plot_data::R{Vector{PlotData}} = []
    #4.2绘制方式
    layout::R{PlotLayout} = PlotLayout(plot_bgcolor="#fff")
end
end