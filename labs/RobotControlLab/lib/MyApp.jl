using Stipple, StipplePlotly, StippleUI, DataFrames, Genie

include("solver.jl")

@reactive mutable struct MyPage <: ReactiveModel
    value::R{Int} = 0

    θ_1::R{RangeData{Int}} = RangeData(20:90)
    θ_2::R{RangeData{Int}} = RangeData(20:90)
    θ_3::R{RangeData{Int}} = RangeData(20:90)

    timespan::R{Float64} = 1.0

    features::R{Vector{String}} = ["最短距离", "最省力"]
    choose::R{String} = "最短距离"

    plot_data::R{Vector{PlotData}} = pl_data([20, 20, 20])
    layout::R{PlotLayout} = PlotLayout(
        plot_bgcolor="#fff",
        showlegend=false,
        width=1000,
        height=750,
        xaxis=[
            PlotLayoutAxis(xy="x", index=1, range=[-3, 3], showgrid=false, visible=false)
        ],
        yaxis=[
            PlotLayoutAxis(xy="y", index=1, range=[0, 3], showgrid=false, visible=false)
        ]
    )

    show_time::R{Float64} = 0.0
    show_θ_1::R{Float64} = 0.0
    show_θ_2::R{Float64} = 1.0
    show_θ_3::R{Float64} = 2.0
    show_ω_1::R{Float64} = 3.0
    show_ω_2::R{Float64} = 4.0
    show_ω_3::R{Float64} = 5.0

    start_opt::R{Matrix{Float64}} = solver([π / 3, -π / 4, π / 2], [-π / 3, π / 4, -π / 5], 1.5)[1]
end

function compute_data(model::MyPage)
    t0 = [
        model.θ_1[].range.start / 100 * π - π / 2,
        model.θ_2[].range.start / 100 * π - π / 2,
        model.θ_3[].range.start / 100 * π - π / 2
    ]
    tf = [
        model.θ_1[].range.stop / 100 * π - π / 2,
        model.θ_2[].range.stop / 100 * π - π / 2,
        model.θ_3[].range.stop / 100 * π - π / 2
    ]
    N = 200
    timespan = model.timespan[]
    mode = model.choose[]
    res = solver(t0, tf, timespan, mode, N)
    degrees = real.(res[1][:, 1:3])
    velocity = real.(res[1][:, 4:6])
    l = collect(0:0.01:1)
    for i in 1:length(degrees[:, 1])
        xs1 = l .* sin(degrees[i, 1])
        ys1 = l .* cos(degrees[i, 1])
        xs2 = l .* sin(degrees[i, 2]) .+ xs1[end]
        ys2 = l .* cos(degrees[i, 2]) .+ ys1[end]
        xs3 = l .* sin(degrees[i, 3]) .+ xs2[end]
        ys3 = l .* cos(degrees[i, 3]) .+ ys2[end]
        model.plot_data[] = [
            PlotData(x=xs1, y=ys1, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER),
            PlotData(x=xs2, y=ys2, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER),
            PlotData(x=xs3, y=ys3, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER)
        ]
        model.show_time[] = i / N * timespan
        model.show_θ_1[] = degrees[i, 1]
        model.show_θ_2[] = degrees[i, 2]
        model.show_θ_3[] = degrees[i, 3]
        model.show_ω_1[] = velocity[i, 1]
        model.show_ω_2[] = velocity[i, 2]
        model.show_ω_3[] = velocity[i, 3]
        sleep(1 / 24)
    end
end

function pl_data(model::MyPage)
    l = collect(0:0.01:1)
    xs1 = l .* sin(model.θ_1[].range.start / 100 * π - π / 2)
    ys1 = l .* cos(model.θ_1[].range.start / 100 * π - π / 2)
    xs2 = l .* sin(model.θ_2[].range.start / 100 * π - π / 2) .+ xs1[end]
    ys2 = l .* cos(model.θ_2[].range.start / 100 * π - π / 2) .+ ys1[end]
    xs3 = l .* sin(model.θ_3[].range.start / 100 * π - π / 2) .+ xs2[end]
    ys3 = l .* cos(model.θ_3[].range.start / 100 * π - π / 2) .+ ys2[end]
    model.plot_data[] = [
        PlotData(x=xs1, y=ys1, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER),
        PlotData(x=xs2, y=ys2, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER),
        PlotData(x=xs3, y=ys3, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER)
    ]
end

function pl_data(starts::Vector)
    l = collect(0:0.01:1)
    xs1 = l .* sin(starts[1] / 100 * π - π / 2)
    ys1 = l .* cos(starts[1] / 100 * π - π / 2)
    xs2 = l .* sin(starts[2] / 100 * π - π / 2) .+ xs1[end]
    ys2 = l .* cos(starts[2] / 100 * π - π / 2) .+ ys1[end]
    xs3 = l .* sin(starts[3] / 100 * π - π / 2) .+ xs2[end]
    ys3 = l .* cos(starts[3] / 100 * π - π / 2) .+ ys2[end]
    return [
        PlotData(x=xs1, y=ys1, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER),
        PlotData(x=xs2, y=ys2, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER),
        PlotData(x=xs3, y=ys3, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER)
    ]
end

function ui(model::MyPage)

    on(model.value) do (_...)
        compute_data(model)
    end
    onany(model.θ_1, model.θ_2, model.θ_3) do (_...)
        pl_data(model)
    end

    page(model, class="container", title="Ai4Lab",
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
              marign: 10px;
              background-color: #FFF;
              border-radius: 5px;
              box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
            }

            .stipple-core .st-module > h5,
            .stipple-core .st-module > h6 {
              border-bottom: 0px !important;
            }
            """
        ),
        [
            heading("Optimal Control for Robot Lab(机器人最优控制实验室)")
            row([
                cell(
                    size=3,
                    [
                        h4("优化目标")
                        Stipple.select(:choose; options=:features)
                        h4("θ₁范围，左端起点(-π/2)，右端终点(π/2)")
                        Stipple.range(1:1:100, :θ_1; label=false, color="blue", labelalways=false)
                        h4("θ₂范围，左端起点(-π/2)，右端终点(π/2)")
                        Stipple.range(1:1:100, :θ_2; label=false, color="blue", labelalways=false)
                        h4("θ₃范围，左端起点(-π/2)，右端终点(π/2)")
                        Stipple.range(1:1:100, :θ_3; label=false, color="blue", labelalways=false)
                        h4("运动时长(s)")
                        StippleUI.slider(1:0.5:4, :timespan, label=true)
                        btn("Click Here To Simulate", color="primary", textcolor="black",
                            @click("value += 1"), size="24px", icon="start")
                    ]
                )
                cell(
                    class="st-module",
                    [
                        h4("仿真结果：")
                        plot(:plot_data, layout=:layout, config="{ displayLogo:false }")
                    ]
                )
                cell(
                    size=2,
                    [
                        h4("t (s)")
                        p([
                            span(model.show_time, @text(:show_time))
                        ])
                        h4("θ₁ (rad)")
                        p([
                            span(model.show_θ_1, @text(:show_θ_1))
                        ])
                        h4("θ₂ (rad)")
                        p([
                            span(model.show_θ_2, @text(:show_θ_2))
                        ])
                        h4("θ₃ (rad)")
                        p([
                            span(model.show_θ_3, @text(:show_θ_3))
                        ])
                        h4("ω₁ (rad/s)")
                        p([
                            span(model.show_ω_1, @text(:show_ω_1))
                        ])
                        h4("ω₂ (rad/s)")
                        p([
                            span(model.show_ω_2, @text(:show_ω_2))
                        ])
                        h4("ω₃ (rad/s)")
                        p(size=15, [
                            span(model.show_ω_3, @text(:show_ω_3))
                        ])
                    ]
                )
            ])
        ]
    )
end
