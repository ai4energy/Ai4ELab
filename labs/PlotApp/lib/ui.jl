```
UI页面布局
```
function ui(model::PlotPage)

    # 绘制图形按钮监测
    on(model.value_plot) do (_...)
        @info (string(now()) * "  操作成功")
        plot_data(model)
    end


    # 删除数据按钮监测
    on(model.value_rm) do (_...)
        remove_data(model)
    end

    # UI页面函数
    page(model,
        class="container",
        title="Ai4energy",
        head_content=Genie.Assets.favicon_support(), # 图标支持
        prepend=style(
            """
            tr:nth-child(even) {
              background: #F8F8F8 !important;
            }

            .st-module {
              marign: 10px;
              background-color: #FFF;
              border-radius: 5px;
              box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
            }

            .stipple-core .st-module > h5,
            .stipple-core .st-module > h4 {
              border-bottom: 0px !important;
            }
            """
        ), # CSS风格
        [
            heading("云绘图实验室") # 大标题
            row([
                btn("删除数据", color="red", textcolor="black", @click("value_rm += 1"), size="24px", [
                    tooltip(contentclass="bg-indigo", contentstyle="font-size: 16px",
                        style="offset: 10px 10px", "点击删除数据")])
                cell(
                    class="st-module", size=3,
                    uploader(label="数据上传", :auto__upload, :multiple, method="POST",
                        url=SERVEURL, field__name="csv_file")
                )
                cell(
                    class="st-module",
                    [
                        h4("日志")
                        p([
                            "状态:"
                            span(model.isSuccess, @text(:isSuccess))
                        ])
                    ]
                )
                btn("绘制图像", color="primary", textcolor="black", @click("value_plot += 1"), size="24px", [
                    tooltip(contentclass="bg-indigo", contentstyle="font-size: 16px",
                        style="offset: 10px 10px", "点击绘制图像")])
            ])  # 第二行布局：删除数据按钮、数据上传、日志、绘制图像按钮
            row([
                cell(
                    class="st-module",
                    [
                        h4("选择绘图模式")
                        Stipple.select(:model_choose; options=:plot_models)
                    ]
                )
                cell(
                    class="st-module",
                    [
                        h4("选择数据区间（百分比）")
                        range(1:1:100,
                            :range_data;
                            label=true,
                            color="blue",
                            labelalways=false,
                            labelvalueleft=Symbol("'Start: ' + range_data.min + '%'"),
                            labelvalueright=Symbol("'End: ' + range_data.max + '%'")
                        )
                    ]
                )
                cell(
                    class="st-module",
                    [
                        h4("散点形状选择")
                        Stipple.select(:symbol_choose; options=:symbol_types)
                    ]
                )
            ]
            ) # 第三行布局：模式选择、选择数据滑动条、散点形状选择
            row([
                cell(
                    class="st-module",
                    [
                        h4("交会图绘制区")
                        plot(:cross_plot_data, layout=:cross_plot_layout, config="{ displayLogo:false }")
                    ]
                )
                cell(
                    class="st-module",
                    [
                        h4("组合图绘制区")
                        plot(:heatmap_plot_data, layout=:heatmap_plot_layout, config="{ displayLogo:false }")
                    ]
                )]
            ) # 第四行布局：交会图绘制区、组合图绘制区
        ]
    )
end