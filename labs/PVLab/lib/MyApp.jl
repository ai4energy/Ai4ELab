using Stipple, StipplePlotly, StippleUI, Genie
include("PV_solver.jl")

module MyApp
using Stipple,StipplePlotly, StippleUI, Genie
@reactive mutable struct MyPage <: ReactiveModel
    V_DATA::R{Vector{Float64}} = []
    I_DATA::R{Vector{Float64}} = []

    Iph::R{Float32} = 0.0
    Io::R{Float32} = 0.0
    n::R{Float32} = 0.0
    Rs::R{Float32} = 0.0
    Rsh::R{Float32} = 0.0
    I_fitting::R{Vector{Float64}} = []

    plot_data::R{Vector{PlotData}} = []
    layout::R{PlotLayout} = PlotLayout(plot_bgcolor="#fff")

    input_process::R{Bool} = false
    fig_process::R{Bool} = false
    V_INPUT::R{String} = ""
    I_INPUT::R{String} = ""
    warin::R{Bool} = true
    input_print::R{String} = ""
    expor_print::R{String} = ""

end
end

function plot_input(model::MyApp.MyPage)
    model.plot_data[] = [PlotData(
        x=model.V_DATA[],
        y=model.I_DATA[],
        plot=StipplePlotly.Charts.PLOT_TYPE_LINE  ,
        name="real",)]
end

function plot_fitting(model::MyApp.MyPage)
    model.plot_data[] = [
        PlotData(
        x=model.V_DATA[],
        y=model.I_DATA[],
        plot=StipplePlotly.Charts.PLOT_TYPE_LINE  ,
        name="real",), 
        PlotData(
        x=model.V_DATA[],
        y=model.I_fitting[],
        plot=StipplePlotly.Charts.PLOT_TYPE_LINE  ,
        name="fitting",)]
end

function ui(model::MyApp.MyPage)

    onany(model.input_process) do (_...)
        if (model.input_process[])
            try
                model.V_DATA[]=eval(Meta.parse(model.V_INPUT[]))
                model.I_DATA[]=eval(Meta.parse(model.I_INPUT[]))
                model.input_print[]="Data Imported!"
                plot_input(model)
            catch
                model.input_print[]="Please Check Your Data!"
            end
            model.input_process[] = false
        end
    end

    onany(model.fig_process) do (_...)
        if (model.fig_process[])
            try
                model.expor_print[]="Is Fitting!"
                model.Iph[],model.Io[],model.n[],model.Rs[],model.Rsh[],model.I_fitting[]=Parameter_fitting(model.V_DATA[],model.I_DATA[])
                model.expor_print[]="Fit Succeed!"
                plot_fitting(model)
            catch
                model.expor_print[]="Fit Failed!"
            end
            model.fig_process[] = false
        end
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
              marign: 20px;
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
            heading("伏安特性曲线拟合虚拟仿真实验室(VA Characteristic Curve Fitting Virtual Simulation Laboratory)")
            row([
                cell(
                    class="st-module",
                    [
                        h2("Please Enter the Data as a List :")
                        textfield("Please input your Voltage data *", :V_INPUT, name = "Voltage", @iif(:warin), :filled, hint = "Voltage(V)", "lazy-rules",
                            rules = "[val => val[0] == '[' && val.length > 0 &&val[val.length-1] == ']' || 'Please type a list']")
                        textfield("Please input your Current data *", :I_INPUT, name = "Current", @iif(:warin), :filled, hint = "Current(A)", "lazy-rules",
                            rules = "[val => val[0] == '[' && val.length > 0 &&val[val.length-1] == ']' || 'Please type a list']")
                        row([
                            cell(
                                class="st-module",
                                [btn("Data Input",@click("input_process = true"),style="font-size: 20px", color="primary", textcolor="black", icon = "download")
                                 span("",@text(:input_print),style="color:green;font-size: 16px")
                                ])
                            cell(
                                class="st-module",
                                [btn("Export Fig",@click("fig_process= true"),style="font-size: 20px", color="green", textcolor="black", icon = "draw")
                                span("",@text(:expor_print),style="color:green;font-size: 16px")
                                ])                                
                            ])
                        row([
                            cell([
                                Html.div("Iph : ", class="text-h2", [
                                span("", @text(:Iph))])
                                ])
                            cell([
                                Html.div("Io : ", class="text-h2", [
                                span("", @text(:Io))])
                                ])
                            cell([
                                Html.div("n : ", class="text-h2", [
                                span("", @text(:n))])
                                ])
                            ])
                        row([
                            cell([
                                Html.div("Rs : ", class="text-h2", [
                                span("", @text(:Rs))])
                                ])
                            cell([
                                Html.div("Rsh : ", class="text-h2", [
                                span("", @text(:Rsh))])
                                ])
                            ])

                    ])
                cell(
                    class="st-module",
                    [
                    h5("Result：")
                    plot(:plot_data, layout=:layout, config="{ displayLogo:false }")
                    ])
                ])
        ])
end

