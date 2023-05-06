using Stipple, StippleUI
using StipplePlotly
using CoolProp
using Printf

include("massdata.jl")

mutable struct xunhuan
    picture::PlotData
    work::Float64
    efficiency::Float64
end

struct StepError <: Exception end
@reactive mutable struct testpage <: ReactiveModel
    #按钮所必要变量 2023-3-1
    value::R{Int} = 0
    click::R{Int} = 0
    isloading::R{Bool} = false

    circle::R{xunhuan} = xunhuan(PlotData(), 0.0, 0.0)
    plot_data::R{Vector{PlotData}} = []
    layout::R{PlotLayout} = pl()
    T1::R{Float64} = 298.0
    Tz::R{Float64} = 500.0
    pw::R{Float64} = 3.0
    continuity::R{Bool} = false
    reheat::R{Bool} = false
    picture::R{Bool} = true
    str_picture::String = "示热图"
    str_work::R{String} = "0.0"
    str_efficiency::R{String} = "0.0"
    mass_number::R{Int} = 1
    mass_selections::R{Vector{String}} = [mass.name for mass in mass_list]
    mass_selection::R{String} = mass_list[1].name
end

pl() = PlotLayout(
    plot_bgcolor="#fff",
    title=PlotLayoutTitle(text="朗肯循环温熵图(示热图)"),
    legend=PlotLayoutLegend(bgcolor="rgb(212,212,212)", font=Font(6)),
    hovermode="closest",
    showlegend=true,
    xaxis=[PlotLayoutAxis(xy="x", index=1,
        title="比熵s(kJ/(K*kg))",
        font=Font(18),
        ticks="outside bottom",
        #side = "bottom",
        #position = 1.0,
        showline=true,
        showgrid=true,
        zeroline=false,
        mirror=true,
        #ticklabelposition = "outside"
    )],
    yaxis=[PlotLayoutAxis(xy="y", index=1,
        showline=true,
        zeroline=true,
        mirror="all",
        showgrid=true,
        title="热力学温度T/K",
        font=Font(18),
        ticks="outside",
        scaleratio=1,
        constrain="domain",
        constraintoward="top",
    )],
)

plPV() = PlotLayout(
    plot_bgcolor="#fff",
    title=PlotLayoutTitle(text="朗肯循环p-v图(示功图)"),
    legend=PlotLayoutLegend(bgcolor="rgb(212,212,212)", font=Font(6)),
    hovermode="closest",
    showlegend=true,
    xaxis=[PlotLayoutAxis(xy="x", index=1,
        title="比体积v(m^3/kg)",
        font=Font(18),
        ticks="outside bottom",
        #side = "bottom",
        #position = 1.0,
        showline=true,
        showgrid=true,
        zeroline=false,
        mirror=true,
        #ticklabelposition = "outside"
    )],
    yaxis=[PlotLayoutAxis(xy="y", index=1,
        showline=true,
        zeroline=true,
        mirror="all",
        showgrid=true,
        title="压力v/MPa",
        font=Font(18),
        ticks="outside",
        scaleratio=1,
        constrain="domain",
        constraintoward="top",
    )],
)

function solveeqution(eqtions, step::Float64, precision::Float64, cauchy::Float64)
    memory = 0
    error = 0
    while true
        memory = eqtions(cauchy)
        if abs(memory) < precision
            return cauchy
        end
        cauchy = cauchy + step
        step = 0.1 * step / abs(eqtions(cauchy) - memory)
        error += 1
        if error > 10^6
            throw(StepError)
        end
    end
end

function integral(x, y)
    n = length(x)
    s = 0
    for i = 1:n-1
        s = s + (y[i] + y[i+1]) * (x[i+1] - x[i]) / 2
    end
    return s
end

function saturationline(mass::Mass, picture::Bool)
    if picture
        sw = [[PropsSI("S", "T", t, "Q", 0, mass.hname) for t = mass.temperature_limit[1]:mass.temperature_limit[2]]
            [PropsSI("S", "T", t, "Q", 1, mass.hname) for t = mass.temperature_limit[2]:-1:mass.temperature_limit[1]]]
        return PlotData(x=sw/1000,
                y=[mass.temperature_limit[1]:mass.temperature_limit[2]; mass.temperature_limit[2]:-1:mass.temperature_limit[1]], 
                name=mass.name * "的饱和线")
    else
        v = [[1/PropsSI("D", "P", p, "Q", 0, mass.hname) for p = mass.pressure_limit[1]:1000:mass.pressure_limit[2]]
            [1/PropsSI("D", "P", p, "Q", 1, mass.hname) for p = mass.pressure_limit[2]:-1000:mass.pressure_limit[1]]]
        return PlotData(x=v,
                y=[mass.pressure_limit[1]:1000:mass.pressure_limit[2]; mass.pressure_limit[2]:-1000:mass.pressure_limit[1]]/10^6, 
                name=mass.name * "的饱和线")
    end
end

function computeRK(T1::Float64, Tz::Float64, pw::Float64, reheat::Bool, mass::Mass, picture::Bool)
    c = xunhuan(PlotData(), 0.0, 0.0)
    x = [3, 1]
    x2 = [1,1]
    p0 = PropsSI("P", "T", T1, "Q", 1, mass.hname) / 10^6
    Ti = 0
    if picture
        s = [PropsSI("S", "T", T1, "Q", 1, mass.hname), PropsSI("S", "T", T1, "Q", 0, mass.hname), PropsSI("S", "T", T1, "Q", 0, mass.hname)]
        T = [T1, T1]
        str = "基础理想朗肯循环"
        S1(t) = PropsSI("S", "T", t, "P|liquid", (p0 + pw) * 10^6, mass.hname) - s[2]
        t0 = solveeqution(S1, 0.001, 0.1, T1)
        T = [T; t0:PropsSI("T", "P", (p0 + pw) * 10^6, "Q", 0, mass.hname)]
        s = [s; PropsSI.("S", "T", T[4:end], "P|liquid", (p0 + pw) * 10^6, mass.hname)]
        T = [T; PropsSI("T", "P", (p0 + pw) * 10^6, "Q", 1, mass.hname)]
        s = [s; PropsSI("S", "P", (p0 + pw) * 10^6, "Q", 1, mass.hname)]
        S2(x) = PropsSI("S", "T|gas", x, "P", (p0 + pw) * 10^6, mass.hname) - s[1]
        t0 = T[end]
        T2 = solveeqution(S2, 0.1, 0.1, t0)
        T = [T; t0:T2]
        s = [s; PropsSI.("S", "T|gas", t0:T2, "P", (p0 + pw) * 10^6, mass.hname)]
        s[end] = PropsSI("S", "T", T1, "Q", 1, mass.hname)
        x[2] = length(T)
        if reheat
            S3(p) = PropsSI("S", "T|gas", Tz, "P", p * 10^6, mass.hname) - s[1]
            p = solveeqution(S3, 0.01, 0.1, p0)
            T = [T; Tz:T2]
            s = [s; PropsSI.("S", "T|gas", Tz:T2, "P", p * 10^6, mass.hname)]
            x[2] = length(T)
            T = [T; T1]
            s = [s; PropsSI("S", "T|gas", T2, "P", p * 10^6, mass.hname)]
            str = "带有再热的理想朗肯循环"
        end
        T = [T; T1]
        s = [s; PropsSI("S", "T", T1, "Q", 1, mass.hname)] / 1000
        c.work = integral(s, T)
        c.efficiency = c.work / integral(s[x[1]:x[2]], T[x[1]:x[2]]) * 100
        c.picture = PlotData(x=s, y=T, name=str)
    else
        str = "基础理想朗肯循环"
        h3 = PropsSI("H","T",T1,"Q",1,mass.hname)/1000
        h4 = PropsSI("H","T",T1,"Q",0,mass.hname)/1000
        v = [1/PropsSI("D", "T", T1, "Q", 1, mass.hname), 1/PropsSI("D", "T", T1, "Q", 0, mass.hname)]
        p = [p0;PropsSI("P", "T", T1, "Q", 0, mass.hname)/10^6:0.1:(p0+pw)]
        p = [p;(p0+pw)]
        s1 = PropsSI("S","T",T1,"Q",0,mass.hname)
        s2 = PropsSI("S","T",T1,"Q",1,mass.hname)
        for i in p[3:end]
            Sp1(t) = PropsSI("S","T",t,"P|liquid",i*10^6,mass.hname) - s1
            Ti = solveeqution(Sp1,0.001,0.1,T1)
            v = [v;1/PropsSI("D","T",Ti,"P|liquid",i*10^6,mass.hname)]
        end
        h1 = PropsSI("H","T",Ti,"P|liquid",(p0+pw)*10^6,mass.hname)/1000
        x2[1] = length(p)
        T0 = PropsSI("T","P",(p0+pw)*10^6,"Q",1,mass.hname)
        Sp2(t) = PropsSI("S","T|gas",t,"P",(p0+pw)*10^6,mass.hname) - s2        
        Ti = solveeqution(Sp2,0.1,0.1,T0)
        h2 = PropsSI("H","T|gas",Ti,"P",(p0+pw)*10^6,mass.hname)/1000
        vi = 1/PropsSI("D","T|gas",Ti,"P",(p0+pw)*10^6,mass.hname)
        k = PropsSI("CPMASS","T|gas",Ti,"P",(p0+pw)*10^6,mass.hname)/PropsSI("CVMASS","T|gas",Ti,"P",(p0+pw)*10^6,mass.hname)
        c0 = (p0+pw)*vi^k
        if reheat
            str = "带有再热的理想朗肯循环"
            Sp3(p) = PropsSI("S","T|gas",Tz,"P",p*10^6,mass.hname) - s2
            pj0 = PropsSI("P","T",Tz,"Q",1,mass.hname)/10^6
            pj = solveeqution(Sp3,-0.1,0.1,pj0)
            h5 = PropsSI("H","T|gas",Tz,"P",pj*10^6,mass.hname)/1000
            p = [p;(p0+pw):-0.1:pj]
            v = [(c0 ./ ((p0+pw):-0.1:pj)) .^ (1/k)]
            p = [p;pj]
            v = [(c0/pj)^(1/k)]
            vj = 1/PropsSI("D","T|gas",Ti,"P",pj*10^6,mass.hname)
            h6 = PropsSI("H","T|gas",Ti,"P",pj*10^6,mass.hname)/1000
            k1 = PropsSI("CPMASS","T|gas",Ti,"P",pj*10^6,mass.hname)/PropsSI("CVMASS","T|gas",Ti,"P",pj*10^6,mass.hname)
            c1 = pj*vj^k1
            p = [p;pj:-0.1:p0]
            v = [v;(c1 ./ (pj:-0.1:p0)) .^ (1/k1)]
            p = [p;p0]
            v = [(c1/p0)^(1/k1)]
            q = h2 - h1 + h6 - h5
            w = h2 - h5 + h6 - h3 - (h1 - h4)
        else
            p = [p;(p0+pw):-0.1:p0]
            v = [v;(c0 ./ ((p0+pw):-0.1:p0)) .^ (1/k)]
            p = [p;p0]
            v = [v;(c0/p0)^(1/k)]
            q = h2 - h1
            w = h2 - h3 - (h1 - h4)
        end
        p = [p;p0]
        v = [v;1/PropsSI("D","P",p0*10^6,"Q",1,mass.hname)]
        c.work = w
        c.efficiency = c.work / q * 100
        c.picture = PlotData(x=v, y=p, name=str)
    end
    return c
end

function xiabiao(array::Vector{Mass}, value::String)
    for i in eachindex(array)
        value == array[i].name ? (return i) : continue
    end
end

function ui(model::testpage)
    btn1 = btn("开始计算", 
                loading=:isloading,
                color="indigo-8",
                textcolor="white",
                size="15px",
                @click("value += 1"),
                [
                    tooltip(contentclass="bg-indigo",
                        contentstyle="font-size: 16px",
                        style="offset: 1000px 1000px",
                        "点击按钮以开始仿真"
                    )
                ]
    )

    onany(model.mass_selection) do (_...)
        model.mass_number[] = xiabiao(mass_list, model.mass_selection[])
    end

    onany(model.value) do (_...)
        if model.click[] == 0
            model.plot_data[] = [saturationline(mass_list[model.mass_number[]], model.picture[])]
        end
        model.click[] += 1
        model.isloading[] = true
        if model.picture[]
            model.str_picture = "示热图"
            model.layout[] = pl()
        else
            model.str_picture = "示功图"
            model.layout[] = plPV()
        end
        try
            model.circle[] = computeRK(model.T1[], model.Tz[], model.pw[], model.reheat[], mass_list[model.mass_number[]], model.picture[])
        catch e
            if isa(e,StepError)
                @info "警告!迭代步数过多,程序停止计算!建议改变参数,重新计算!"
                notify(model,"警告!迭代步数过多,程序停止计算!建议改变参数,重新计算!")
            elseif isa(e,ErrorException)
                @info "错误!温度或压强超出了范围,请调整为合适值再做计算!"
                notify(model,"错误!温度或压强超出了范围,请调整为合适值再做计算!")
            end
        end
        model.str_work[] = @sprintf("%6.3f", model.circle[].work)
        model.str_efficiency[] = @sprintf("%2.2f", model.circle[].efficiency)
        if model.continuity[]
            model.plot_data[] = [model.plot_data[]; model.circle[].picture]
        else
            model.plot_data[] = [saturationline(mass_list[model.mass_number[]], model.picture[]), model.circle[].picture]
        end
        model.isloading[] = false
    end


    page(model,
        class="container",
        title="朗肯循环实验室",
        head_content=Genie.Assets.favicon_support(),
        prepend=style(
            """
            tr:nth-child(even) {
              background: #F8F8F8 !important;
            }
            .modebar {
              display: none!important;
            }
            .st-module {
              marign: 5px;
              background-color: #FFF;
              border-radius: 5px;
              padding: 15px 15px 0px 15px;
              box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
            }
            .st-module1 {
              position: relative;
			  left: 10px;
              right: 30px;
			  background-color: #FFF;
              padding: 10px;
              border-radius: 5px;
			  box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
            }
            .st-module2 {
              position: relative;
			  left: 10px;
			  marign: 10px;
			  background-color: #FFF;
              padding: 10px;
              border-radius: 5px;
			  box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
            }
            .st-module3 {
                marign: 5px;
                padding: 5px 5px 5px 25px;
                background: rgba(255,255,255,1);
                border-radius: 5px;
                box-shadow: 0px 4px 10px rgba(17,64,108,0.04);
            }
            .st-module5 {
                position: relative;
                top: 0px;
                left: 25px;
                height:550px;
                width:1490px;
                background-color:rgba(255,255,255,0);
                border-radius: 5px;
            }
            .st-module6 {
                marign:0px;
                background-color: #FFF;
                border-radius: 5px;
                padding: 5px;
                box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
            }
            .stipple-core .st-module > h5,
            .stipple-core .st-module > h6 {
              border-bottom: 0px !important;
            }
            """
        ),
        [
            row([
			cell(class="st-module1", [
				row([   
					h1("朗肯循环实验室(Rankine Cycle Laboratory)")  
					])
				])
                checkbox(label="显示连续变化",fieldname=:continuity,dense=true,class="st-module2",color="indigo-8")
                checkbox(label="引入再热",fieldname=:reheat,dense=true,class="st-module2",color="indigo-8")
                checkbox(label=model.str_picture, fieldname=:picture, dense=true,class="st-module2",color="indigo-8")
			])
            row(class="st-module5",[
                
                cell(
                    class="st-module6", size=8,
                    [
                        h5("仿真结果：&nbsp&nbsp")
                        plot(:plot_data, layout=:layout, config="{ displayLogo:false }")
                    ]
                )
                cell([
                    cell(
                        cell(
                            class="st-module3",
                            [
                                select(:mass_selection, options=:mass_selections,color="indigo-8")
                            ]
                        )
                    )
                    row([
                        cell(
                            class="st-module",
                            [
                                h6("&nbsp&nbsp 输出净功:&nbsp&nbsp")
                                h6("", @text(:str_work))
                                h6("&nbspkJ/kg")
                            ])
                    ])
                    row(class="st-module",[

                                h6("&nbsp&nbsp 循环热效率:&nbsp&nbsp")
                                h6("", @text(:str_efficiency))
                                h6("&nbsp%")

                    ])
                    row([
                        cell(
                            class="st-module",
                            [
                                h6("&nbsp&nbsp 泵功(增压/MPa)")
                                slider(0:0.5:20,
                                    @data(:pw);
                                    label=true,color="indigo-8")
                            ]
                        )])
                    row([
                        cell(
                            class="st-module",
                            [
                                h6("&nbsp&nbsp 冷却温度(K)")
                                slider(200:800,
                                    @data(:T1);
                                    label=true,color="indigo-8")
                            ]
                        )])
                    row([
                        cell(
                            class="st-module",
                            [
                                h6("&nbsp&nbsp 再热温度(K)", @showif(:reheat))
                                slider(200:1000,
                                    @data(:Tz),
                                    @showif(:reheat),
                                    label=true,color="indigo-8")
                            ]
                        )])
                    row([
                        cell(class="st-module",[
                        btn1
                        h6(["&nbsp&nbsp绘制次数: ",span(model.click, @text(:click))])
                    ])
                    ])
                ])
            ])
        ])
end

route("/") do
    testpage |> init |> ui |> html
end

up(8889, open_browser=true)
