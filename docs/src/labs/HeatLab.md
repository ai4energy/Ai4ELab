# HeatLab

!!! tip
    Designed By: YJY

    Email:522432938@qq.com

    [云实验室网页链接](https://ai4energy-heatlab.herokuapp.com/)。PS: 首次进入需要等待较长时间，Heroku上的App需要重启。

    如有错误，请批评指正。欢迎讨论交流。

## 设计原理

* [二维平板换热原理](https://ai4energy.github.io/Ai4EDocs/dev/Simulation/DE_heattran/)
* 将平板离散成10*10的二维网格
* 选择不同的：
  1. 平板初始温度
  2. 环境温度初值
  3. 环境温度变化函数
  4. 求解时间域
  5. 环境温度变化函数中t的系数

## 交互要素

* row-1:
  * 滑动条：平板初始温度
  * 滑动条：环境温度初值
  * 滑动条：环境温度变化函数中t的系数
  * 滑动条：求解时间域
  * 选择框：环境温度
* row-2:
  * 按钮：仿真触发
  * 文本框：仿真次数记录
* row-3
  * 绘图区：图显示画布——等高线图
  * 表格：显示平板仿真温度结果

## 操作说明

选择不同的交互要素，点击`SIMULATION!`开始仿真。

## 实验演示

![图一](../assets/heatlab.gif)
