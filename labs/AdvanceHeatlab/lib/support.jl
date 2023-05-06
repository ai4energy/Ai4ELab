using Stipple, StipplePlotly, StippleUI, Genie, CSV
using DataFrames, DelimitedFiles

include("module.jl")
include("solver.jl")

#设置绘图函数
contourPlot(z, n, m, Lx, Ly) = PlotData(
    x=collect(range(0, Lx, length=n)),
    y=collect(range(Ly, 0, length=m)),
    z=[z[i, :] for i in 1:m],
    plot=StipplePlotly.Charts.PLOT_TYPE_CONTOUR,
    contours=Dict("start" => 0, "end" => 1000),
    name="test",
)


function change(mo::MyApp.MyPage)
    mo.h[5] = eval(Meta.parse(mo.n[]))
    mo.h[6] = eval(Meta.parse(mo.m[]))
    mo.h[7] = eval(Meta.parse(mo.Lx[]))/mo.h[5]
    mo.h[8] = eval(Meta.parse(mo.Ly[]))/mo.h[6]
    mo.h[9] = eval(Meta.parse(mo.a[]))
    mo.h[10] = eval(Meta.parse(mo.density[]))
    mo.h[11] = eval(Meta.parse(mo.c[]))*1000
    #西边
    if mo.selection1[] == "第一类边界条件(温度/°C)"
        boundaryConditions[1].serialNumber = 1
        boundaryConditions[1].bt = mo.funcstr1[]
        mo.showinput1[] = false
    elseif mo.selection1[] == "第二类边界条件(热流密度/(W/m^2))"
        boundaryConditions[1].serialNumber = 2
        boundaryConditions[1].qw = mo.funcstr1[]
        mo.showinput1[] = false
    elseif mo.selection1[] == "第三类边界条件(对流换热)"
        boundaryConditions[1].serialNumber = 3
        boundaryConditions[1].Tf = mo.funcstr1[]
        mo.h[1] = eval(Meta.parse(mo.h1[]))
        mo.showinput1[] = true
    end
    #北边
    if mo.selection2[] == "第一类边界条件(温度/°C)"
        boundaryConditions[2].serialNumber = 1
        boundaryConditions[2].bt = mo.funcstr2[]
        mo.showinput2[] = false
    elseif mo.selection2[] == "第二类边界条件(热流密度/(W/m^2))"
        boundaryConditions[2].serialNumber = 2
        boundaryConditions[2].qw = mo.funcstr2[]
        mo.showinput2[] = false
    elseif mo.selection2[] == "第三类边界条件(对流换热)"
        boundaryConditions[2].serialNumber = 3
        boundaryConditions[2].Tf = mo.funcstr2[]
        mo.h[2] = eval(Meta.parse(mo.h2[]))
        mo.showinput2[] = true
    end
    #东边
    if mo.selection3[] == "第一类边界条件(温度/°C)"
        boundaryConditions[3].serialNumber = 1
        boundaryConditions[3].bt = mo.funcstr3[]
        mo.showinput3[] = false
    elseif mo.selection3[] == "第二类边界条件(热流密度/(W/m^2))"
        boundaryConditions[3].serialNumber = 2
        boundaryConditions[3].qw = mo.funcstr3[]
        mo.showinput3[] = false
    elseif mo.selection3[] == "第三类边界条件(对流换热)"
        boundaryConditions[3].serialNumber = 3
        boundaryConditions[3].Tf = mo.funcstr3[]
        mo.h[3] = eval(Meta.parse(mo.h3[]))
        mo.showinput3[] = true
    end
    #南边
    if mo.selection4[] == "第一类边界条件(温度/°C)"
        boundaryConditions[4].serialNumber = 1
        boundaryConditions[4].bt = mo.funcstr4[]
        mo.showinput4[] = false
    elseif mo.selection4[] == "第二类边界条件(热流密度/(W/m^2))"
        boundaryConditions[4].serialNumber = 2
        boundaryConditions[4].qw = mo.funcstr4[]
        mo.showinput4[] = false
    elseif mo.selection4[] == "第三类边界条件(对流换热)"
        boundaryConditions[4].serialNumber = 3
        boundaryConditions[4].Tf = mo.funcstr4[]
        mo.h[4] = eval(Meta.parse(mo.h4[]))
        mo.showinput4[] = true
    end
end

function compute_data(model::MyApp.MyPage)
    timefield = model.timefield[]
    innerheat = model.innerheat[]
    u0=model.u0[]
    try 
        res = get_data(u0, timefield, boundaryConditions, innerheat, [model.h[9:11];model.h[1:4]],model.h[5:8])
        len = length(res[1, 1, :])
        for i in 1:len
            model.plot_data[] = [contourPlot(res[:, :, i],trunc(Int,model.h[5]),trunc(Int,model.h[6]),model.h[7],model.h[8])]
            model.tableData[] = DataTable(
                DataFrame(round.(res[:, :, i], digits=2), ["$j" for j in 1:trunc(Int,model.h[5])]))
            sleep(1 / 30)
        end
        @info "仿真成功, 请检查结果!"
        notify(model,"仿真成功, 请检查结果!")
    catch e
        @info "计算失败!请检查初值条件,或调整计算步长!"
        notify(model,"计算失败!  请检查初值条件,或调整计算步长!")
    end
    nothing
end
