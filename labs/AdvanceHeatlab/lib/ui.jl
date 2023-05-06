include("support.jl")
include("init.jl")
using Genie, Stipple, StippleUI
using Genie.Requests, Genie.Renderer

Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

#创建网页
function ui(model::MyApp.MyPage)
    btn1 = btn("开始计算", loading=:isloading,
        color="brand",
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
    #交互循环
    onany(model.value) do (_...)
        model.isloading[]=true
        model.click[] += 1
        change(model)
        model.u0[] = zeros(trunc(Int, model.h[5] * model.h[6]))
        if (sort(readdir(FILE_PATH)) != String[])
            model.u0[] = vec(float(open(readdlm, joinpath(FILE_PATH, "file.txt"))))
        end
        if length(model.u0[]) != model.h[5] * model.h[6]
            @info "初值数组长度与格点数目不匹配, 请检查!  程序将以零初值计算!"
            notify(model,"初值数组长度与格点数目不匹配, 请检查!  程序将以零初值计算!")
            model.u0[] = zeros(trunc(Int, model.h[5] * model.h[6]))
        end
        compute_data(model)
        model.isloading[]=false
    end

    onany(model.selection1) do (_...)
        change(model)
    end

    onany(model.selection2) do (_...)
        change(model)
    end

    onany(model.selection3) do (_...)
        change(model)
    end

    onany(model.selection4) do (_...)
        change(model)
    end

    page(model,
        class="container",
        title="二维平板换热虚拟仿真实验室",
        head_content=Genie.Assets.favicon_support(),
        prepend=style(
            """
            tr:nth-child(even) {
              background: rgba(138,171,202,0.3) !important;
            }

            .bg-brand {
                background: #11406c !important;
            }

            .text-brand {
                color: #11406c !important;
            }

            .modebar {
              display: none!important;
            }
            .heading {
                background-color: white;
                color: black;
                text-align:left;
            }
            .st-module {
              position: relative;
              left: 30px;
              padding: 5px;
              border-radius: 5px;
            }
     
            .st-module1 {
                height: 180px;
                width: 300px;
                marign: 20px;
                padding: 15px;
                background: rgba(255,255,255,0.04);
                border-radius: 5px;
                box-shadow: 0px 4px 10px rgba(17,64,108,0.04);
            }
            .st-module2 {
                marign: 5px;
                padding: 5px;
                background: rgba(255,255,255,1);
                border-radius: 5px;
                box-shadow: 0px 4px 10px rgba(17,64,108,0.04);
            }
            .st-module3 {
                height: 55px;
                width: 260px;
                position: relative;
                left: 430px;
                background: rgba(255,255,255,0);
                border-radius: 5px;
            }
            .st-module4 {
                height: 67px;
                width: 260px;
                position: relative;
                left: 430px;
                padding: 7px;
                background: rgba(255,255,255,1);
                border-radius: 5px;
            }
            .st-module5 {
                position: relative;
                top: 0px;
                height:550px;
                width:1500px;
                background-color:rgba(255,255,255,0);
                border-radius: 5px;
            }
            .st-module6 {
                position: relative;
                left: 40px;
                height:400px;
                width:1100px;
                background-color: rgba(255,255,255,1);
                border-radius: 5px;
                box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
            }
            .st-module7 {
                height: 500px;
                width: 300px;
                marign: 20px;
                padding: 15px;
                background: rgba(255,255,255,0.04);
                border-radius: 5px;
                box-shadow: 0px 4px 10px rgba(17,64,108,0.04);
            }
            .stipple-core .st-module > h5,
            .stipple-core .st-module > h6 {
              border-bottom: 0px !important;
            }
            """
        ),
        [
            row([
                cell(class="st-module", [
                    row([   
                        h1("二维平板传热实验室(Two-dimensional Flat Plate Heat Transfer Lab)")  
                        ])
                    ])
                uploader(label="初始温度上传",
                    :auto__upload,
                    method="POST",
                    url=SERVEURL,
                    field__name="txt",
                    color="brand"
                )
            ])
            row(class="st-module5",
                [
                    cell([
                        row(class="st-module6",
                            [
                                cell([
                                    row([
                                        h4("&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp平板等温线图&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp"
                                        )
                                        btn("数据表格",
                                            push=true,
                                            color="brand",
                                            size="15px",
                                            padding="0px 28px",
                                            [
                                                popupproxy([
                                                    cell(class="st-module2",
                                                        [
                                                            h5("平板温度分布数据")
                                                            table(:tableData; pagination=:credit_data_pagination, label=false, flat=true)
                                                        ]
                                                    )
                                                ])
                                            ]
                                        )
                                    ])
                                    plot(:plot_data, layout=:layout, config="{ displayLogo:false }")
                                ])
                            ]
                        )
                    ])
                    cell([
                        row(class="st-module3",
                            [
                                btn("仿真参数设置", 
                                    push=true, 
                                    textcolor= "brand",
                                    color="white",size="25px", 
                                    padding="0px 54px",
                                    [
                                        popupproxy([    
                                            cell(class="st-module7",
                                                [
                                                    cell(class="st-module2",
                                                        [
                                                            h6("平板长度(m)")
                                                            input("", @bind(:Lx))
                                                            h6("平板横向格点个数")
                                                            input("", @bind(:n))
                                                            h6("平板宽度(m)")
                                                            input("", @bind(:Ly))
                                                            h6("平板纵向格点个数")
                                                            input("", @bind(:m))
                                                            h6("平板热扩散系数(m^2/s)")
                                                            input("", @bind(:a))
                                                            h6("平板密度(kg/m^3)")
                                                            input("", @bind(:density))
                                                            h6("平板热容(kJ/(K*kg))")
                                                            input("", @bind(:c))
                                                            h6("仿真时域(s)")
                                                            input("", @bind(:timefield))
                                                        ]
                                                    )
                                                ]
                                            )
                                        ])
                                    ]
                                )
                            ]
                        )
                        
                        row(class="st-module3",
                            [
                                btn("西边条件", push=true, textcolor="brand", color="white", size="25px", padding="0px 80px", [
                                    popupproxy([
                                        cell(
                                            class="st-module1",
                                            [
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        Stipple.select(:selection1, options=:selections, color="indigo-8", label="West")
                                                    ])
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        h6("关于t(时间/s)的表达式:")
                                                        input("", @bind(:funcstr1))
                                                        h6("对流换热系数(W/m^2)", @showif(:showinput1))
                                                        input("", @bind(:h1), @showif(:showinput1))
                                                    ])
                                            ])
                                    ])
                                ])
                            ])
                        row(class="st-module3",
                            [
                                btn("北边条件", push=true, textcolor="brand", color="white", size="25px", padding="0px 80px", [
                                    popupproxy([
                                        cell(
                                            class="st-module1",
                                            [
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        Stipple.select(:selection2, options=:selections, color="indigo-8", label="North")
                                                    ])
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        h6("关于t(时间/s)的表达式:")
                                                        input("", @bind(:funcstr2))
                                                        h6("对流换热系数(W/m^2)", @showif(:showinput2))
                                                        input("", @bind(:h2), @showif(:showinput2))
                                                    ])
                                            ])
                                    ])
                                ])
                            ])
                        row(class="st-module3",
                            [
                                btn("东边条件", push=true, textcolor="brand", color="white", size="25px", padding="0px 80px", [
                                    popupproxy([
                                        cell(
                                            class="st-module1",
                                            [
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        Stipple.select(:selection3, options=:selections, color="indigo-8", label="East")
                                                    ])
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        h6("关于t(时间/s)的表达式:")
                                                        input("", @bind(:funcstr3))
                                                        h6("对流换热系数(W/m^2)", @showif(:showinput3))
                                                        input("", @bind(:h3), @showif(:showinput3))
                                                    ])
                                            ])
                                    ])
                                ])
                            ])
                        row(class="st-module3",
                            [
                                btn("南边条件", push=true, textcolor="brand", color="white", size="25px", padding="0px 80px", [
                                    popupproxy([
                                        cell(
                                            class="st-module1",
                                            [
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        Stipple.select(:selection4, options=:selections, color="indigo-8", label="South")
                                                    ])
                                                cell(
                                                    class="st-module2",
                                                    [
                                                        h6("关于t(时间/s)的表达式:")
                                                        input("", @bind(:funcstr4))
                                                        h6("对流换热系数(W/m^2)", @showif(:showinput4))
                                                        input("", @bind(:h4), @showif(:showinput4))
                                                    ])
                                            ])
                                    ])
                                ])
                            ])
                        row(class="st-module4",
                            [
                                cell([
                                    row([
                                        h6("内热源:&nbsp&nbsp")
                                        input("", @bind(:innerheat))
                                    ])
                                ])
                            ]
                        )
                        row(class="st-module4",
                            [
                                cell([
                                    row([btn1

                                        h6(["&nbsp&nbsp仿真次数:", span(model.click, @text(:click))])
                                    ])
                                ])
                            ]
                        )
                    ])
                ]
            )
        ]
    )
end
