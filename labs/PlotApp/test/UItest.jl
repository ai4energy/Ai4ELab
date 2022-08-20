using Genie, Genie.Renderer.Html, Stipple, StipplePlotly


pl1 = PlotData(x=1:3, y=4:6, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER)

pl2 = PlotData(x=20:10:30, y=50:10:70, plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER, xaxis="x2", yaxis="y")


plotdata = [pl1, pl2];

# Layout

layout = PlotLayout(
    # title=PlotLayoutTitle(text="Multiple Mixed Subplots", font=Font(24)),
    showlegend=false,
    width=500, height=1200,
    # grid=PlotLayoutGrid(rows=2, columns=2, pattern="independent"),
    xaxis=[
        PlotLayoutAxis(xy="x", index=1, domain=[0, 0.7], side="top", title="GR", title_standoff=2),
        PlotLayoutAxis(xy="x", index=2, domain=[0.75, 1], side="top", title="VLD", title_standoff=2, showgrid=false),
    ],
    yaxis=[
        PlotLayoutAxis(xy="y", index=1, autorange="reversed", title="Depth", showgrid=false),
        PlotLayoutAxis(xy="y", index=2, showgrid=false),
    ],
)

@reactive mutable struct Model <: ReactiveModel
    data::R{Vector{PlotData}} = plotdata, READONLY
    layout::R{PlotLayout} = layout, READONLY
    config::R{PlotConfig} = PlotConfig(), READONLY
end

function ui(model)
    page(model, class="container", [plot(:data, layout=:layout, config=:config)])
end

route("/") do
    Model |> init |> ui |> html
end

up(open_browser=true)
