# RobotControlLab

机器人最优控制实验室

!!! tip
    Designed By: YJY

    Email:522432938@qq.com

    [云实验室网页链接](https://ai4energy-robotcontrollab.herokuapp.com/)。PS: 首次进入需要等待较长时间，Heroku上的App需要重启。在启动时，会网页报错，稍等一会后刷新即可（调用库太多，启动稍慢，被认为没有响应）。

    如有错误，请批评指正。欢迎讨论交流。

## 设计原理

* [最优控制理论与应用](https://ai4energy.github.io/Ai4EDocs/dev/Control/OptimControl/)
* 机器人控制问题

## 交互要素

* col-1:
  * 选择框：最优目标
  * 区间滑动条：$\theta_1$的始末位置
  * 区间滑动条：$\theta_2$的始末位置
  * 区间滑动条：$\theta_3$的始末位置
  * 滑动条：运动时长
  * 按钮：仿真触发
* row-2:
  * 绘图框
* row-3
  * 时间显示
  * 角度显示
  * 角速度显示

## 操作说明

选择不同的交互要素，点击`CLICK HERE TO SIMULATE!`开始仿真。

## 实验演示

![图一](./assets/robot.gif)
