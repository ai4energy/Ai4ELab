using DifferentialEquations: ODEProblem, solve, Tsit5
#1.1.1热扩散系数
dr = 1.27E-5
#1.1.2密度
density = 1.0
#1.1.3比热容
c = 1.0
a = dr/(density*c)
#1.1.4对流换热系数
# h = [10.0,10.0,0.0,10.0]
#1.2表征格点个数(x,y方向离散步长相同)
n = 10
m = 10
#1.3板长
Lx = 0.2
Ly = 0.2
#1.4离散步长
dx = Lx / n
dy = Ly / m

step = [n,m,dx,dy]
#1.5化简方程所得常数与傅里叶数相差一时间,可以看作时间常数
p = [a,density,c]
#p = [a,density,c,h[1],h[2],h[3],h[4]]

mutable struct boundaryCondition
    serialNumber::Int
    bt::String
    qw::String
    Tf::String
end

boundaryConditions = [boundaryCondition(1, "0", "0", "0") for i = 1:4]

#字符串转换函数
function fcnFromString(s)
    f = eval(Meta.parse("t -> " * s))
    return t -> Base.invokelatest(f, t)
end

#索引函数
function f(i, j, n)
    return (i - 1) * n + j
end

function get_data(u::Vector{Float64},time::Float64, boundaryConditions::Vector{boundaryCondition}, innerheat::String, p::Vector{Float64},step::Vector)
    #1.6.1设置内热源
    internalHeatSource = fcnFromString(innerheat)
    Tf1 = fcnFromString(boundaryConditions[1].Tf)
    Tf2 = fcnFromString(boundaryConditions[2].Tf)
    Tf3 = fcnFromString(boundaryConditions[3].Tf)
    Tf4 = fcnFromString(boundaryConditions[4].Tf)
    n = trunc(Int,step[1])
    m = trunc(Int,step[2])
    dx = step[3]
    dy = step[4]

    #4.初始化温度场
    u0=u
    
    #3.DifferentialEquations所要求的问题表示函数,dT为一阶导数,T为温度函数,t为时间(自变量),p为常数
    #本例相当于把温度场离散化后,将各个格点温度视作时间的一元函数,共同建立一个一阶常微分方程组
    #以达到将偏微分方程(热传导方程)化简的目的.完全离散可能存在较大误差,故部分离散后可利用DifferentialEquations
    #获得较为精确的解.
    function heat!(dT::Vector{Float64}, T::Vector{Float64}, p::Vector{Float64}, t::Float64)
        # 内部节点
        for i in 2:m-1
            for j in 2:n-1
                dT[f(i,j,n)] = p[1]*(T[f(i+1,j,n)]+T[f(i-1,j,n)]-2*T[f(i,j,n)])/dy^2+
                p[1]*(T[f(i,j+1,n)]+T[f(i,j-1,n)]-2*T[f(i,j,n)])/dx^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        end
        # 边边界节点
        #西边
        if boundaryConditions[1].serialNumber == 1
            #第一类边界条件
            bt1 = fcnFromString(boundaryConditions[1].bt)
            for i in 2:m-1
                T[f(i,1,n)] = bt1(t)
            end
        elseif boundaryConditions[1].serialNumber == 2
            #第二类边界条件
            qw1 = fcnFromString(boundaryConditions[1].qw)
            for i in 2:m-1
                dT[f(i,1,n)] = 2*qw1(t)/(p[2]*p[3]*dx)+
                2*p[1]*(T[f(i,2,n)]-T[f(i,1,n)])/dx^2+
                p[1]*(T[f(i+1,1,n)]-2*T[f(i,1,n)]+T[f(i-1,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        elseif boundaryConditions[1].serialNumber == 3
            #第三类边界条件
            for i in 2:m-1
                dT[f(i,1,n)] = 2*p[4]*(Tf1(t)-T[f(i,1,n)])/(p[2]*p[3]*dx)+
                2*p[1]*(T[f(i,2,n)]-T[f(i,1,n)])/dx^2+
                p[1]*(T[f(i+1,1,n)]-2*T[f(i,1,n)]+T[f(i-1,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        end
        #北边
        if boundaryConditions[2].serialNumber == 1
            #第一类边界条件
            bt2 = fcnFromString(boundaryConditions[2].bt)
            for j in 2:n-1
                T[f(1,j,n)] = bt2(t)
            end
        elseif boundaryConditions[2].serialNumber == 2
            #第二类边界条件
            qw2 = fcnFromString(boundaryConditions[2].qw)
            for j in 2:n-1
                dT[f(1,j,n)] = 2*qw2(t)/(p[2]*p[3]*dy)+
                2*p[1]*(T[f(2,j,n)]-T[f(1,j,n)])/dy^2+
                p[1]*(T[f(1,j+1,n)]-2*T[f(1,j,n)]+T[f(1,j-1,n)])/dx^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        elseif boundaryConditions[2].serialNumber == 3
            #第三类边界条件
            for j in 2:n-1
                dT[f(1,j,n)] = 2*p[5]*(Tf2(t)-T[f(1,j,n)])/(p[2]*p[3]*dy)+
                2*p[1]*(T[f(2,j,n)]-T[f(1,j,n)])/dy^2+
                p[1]*(T[f(1,j+1,n)]-2*T[f(1,j,n)]+T[f(1,j-1,n)])/dx^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        end
        #东边
        if boundaryConditions[3].serialNumber == 1
            #第一类边界条件
            bt3 = fcnFromString(boundaryConditions[3].bt)
            for i in 2:m-1
                T[f(i,n,n)] = bt3(t)
            end
        elseif boundaryConditions[3].serialNumber == 2
            #第二类边界条件
            qw3 = fcnFromString(boundaryConditions[3].qw)
            for i in 2:m-1
                dT[f(i,n,n)] = 2*qw3(t)/(p[2]*p[3]*dx)+
                2*p[1]*(T[f(i,n-1,n)]-T[f(i,n,n)])/dx^2+
                p[1]*(T[f(i+1,n,n)]-2*T[f(i,n,n)]+T[f(i-1,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        elseif boundaryConditions[3].serialNumber == 3
            #第三类边界条件
            for i in 2:m-1
                dT[f(i,n,n)] = 2*p[6]*(Tf3(t)-T[f(i,n,n)])/(p[2]*p[3]*dx)+
                2*p[1]*(T[f(i,n-1,n)]-T[f(i,n,n)])/dx^2+
                p[1]*(T[f(i+1,n,n)]-2*T[f(i,n,n)]+T[f(i,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        end
        #南边
        if boundaryConditions[4].serialNumber == 1
            #第一类边界条件
            bt4 = fcnFromString(boundaryConditions[4].bt)
            for j in 2:n-1
                T[f(m,j,n)] = bt4(t)
            end
        elseif boundaryConditions[4].serialNumber == 2
            #第二类边界条件
            qw4 = fcnFromString(boundaryConditions[4].qw)
            for j in 2:n-1
                dT[f(m,j,n)] = 2*qw4(t)/(p[2]*p[3]*dy)+
                2*p[1]*(T[f(m-1,j,n)]-T[f(m,j,n)])/dy^2+
                p[1]*(T[f(m,j+1,n)]-2*T[f(m,j,n)]+T[f(m,j-1,n)])/dx^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        elseif boundaryConditions[4].serialNumber == 3
            #第三类边界条件
            for j in 2:n-1
                dT[f(m,j,n)] = 2*p[7]*(Tf4(t)-T[f(m,j,n)])/(p[2]*p[3]*dy)+
                2*p[1]*(T[f(m-1,j,n)]-T[f(m,j,n)])/dy^2+
                p[1]*(T[f(m,j+1,n)]-2*T[f(m,j,n)]+T[f(m,j-1,n)])/dx^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        end
        # 角边界
        #西北角和西南角
        if boundaryConditions[1].serialNumber == 1
            bt1 = fcnFromString(boundaryConditions[1].bt)
            if boundaryConditions[2].serialNumber == 1
                bt2 = fcnFromString(boundaryConditions[2].bt)
                T[f(1,1,n)] = (bt1(t) + bt2(t))/2
            else
                T[f(1,1,n)] = bt1(t)
            end
            if boundaryConditions[4].serialNumber == 1
                bt4 = fcnFromString(boundaryConditions[4].bt)
                T[f(m, 1, n)] = (bt1(t) + bt4(t))/2
            else
                T[f(m, 1, n)] = bt1(t)
            end
        elseif boundaryConditions[1].serialNumber == 2
            qw1 = fcnFromString(boundaryConditions[1].qw)
            if boundaryConditions[2].serialNumber == 1
                bt2 = fcnFromString(boundaryConditions[2].bt)
                T[f(1,1,n)] = bt2(t)
            elseif boundaryConditions[2].serialNumber == 2
                qw2 = fcnFromString(boundaryConditions[2].qw)
                dT[f(1,1,n)] = 2*(qw1(t)/dx + qw2(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,2,n)]-T[f(1,1,n)])/dx^2+
                2*p[1]*(T[f(2,1,n)]-T[f(1,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[2].serialNumber == 3
                dT[f(1,1,n)] = 2*(qw1(t)/dx+p[5]*(Tf2(t)-T[f(1,1,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,2,n)]-T[f(1,1,n)])/dx^2+
                2*p[1]*(T[f(2,1,n)]-T[f(1,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
            if boundaryConditions[4].serialNumber == 1
                bt4 = fcnFromString(boundaryConditions[4].bt)
                T[f(m,1,n)] = bt4(t)
            elseif boundaryConditions[4].serialNumber == 2
                qw4 = fcnFromString(boundaryConditions[4].qw)
                dT[f(m,1,n)] = 2*(qw1(t)/dx+qw4(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,2,n)]-T[f(m,1,n)])/dx^2+
                2*p[1]*(T[f(m-1,1,n)]-T[f(m,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[4].serialNumber == 3
                dT[f(m,1,n)] = 2*(qw1(t)/dx + p[7]*(Tf4(t)-T[f(m,1,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,2,n)]-T[f(m,1,n)])/dx^2+
                2*p[1]*(T[f(m-1,1,n)]-T[f(m,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        elseif boundaryConditions[1].serialNumber == 3
            if boundaryConditions[2].serialNumber == 1
                bt2 = fcnFromString(boundaryConditions[2].bt)
                T[f(1,1,n)] = bt2(t)
            elseif boundaryConditions[2].serialNumber == 2
                qw2 = fcnFromString(boundaryConditions[2].qw)
                dT[f(1,1,n)] = 2*(p[4]*(Tf1(t)-T[f(1,1,n)])/dx+qw2(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,2,n)]-T[f(1,1,n)])/dx^2+
                2*p[1]*(T[f(2,1,n)]-T[f(1,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[2].serialNumber == 3
                dT[f(1,1,n)] = 2*(p[4]*(Tf1(t)-T[f(1,1,n)])/dx+p[5]*(Tf2(t)-T[f(1,1,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,2,n)]-T[f(1,1,n)])/dx^2+
                2*p[1]*(T[f(2,1,n)]-T[f(1,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
            if boundaryConditions[4].serialNumber == 1
                bt4 = fcnFromString(boundaryConditions[4].bt)
                T[f(m,1,n)] = bt4(t)
            elseif boundaryConditions[4].serialNumber == 2
                qw4 = fcnFromString(boundaryConditions[4].qw)
                dT[f(m,1,n)] = 2*(p[4]*(Tf1(t)-T[f(m,1,n)])/dx+qw4(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,2,n)]-T[f(m,1,n)])/dx^2+
                2*p[1]*(T[f(m-1,1,n)]-T[f(m,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[4].serialNumber == 3
                dT[f(m,1,n)] = 2*(p[4]*(Tf1(t)-T[f(m,1,n)])/dx+p[7]*(Tf4(t)-T[f(m,1,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,2,n)]-T[f(m,1,n)])/dx^2+
                2*p[1]*(T[f(m-1,1,n)]-T[f(m,1,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        end
        #东北角和东南角
        if boundaryConditions[3].serialNumber == 1
            bt3 = fcnFromString(boundaryConditions[3].bt)
            if boundaryConditions[2].serialNumber == 1
                bt2 = fcnFromString(boundaryConditions[2].bt)
                T[f(1,n,n)] = (bt3(t) + bt2(t))/2
            else
                T[f(1,n,n)] = bt3(t)
            end
            if boundaryConditions[4].serialNumber == 1
                bt4 = fcnFromString(boundaryConditions[4].bt)
                T[f(m,n,n)] = (bt3(t) + bt4(t))/2
            else
                T[f(m,n,n)] = bt3(t)
            end
        elseif boundaryConditions[3].serialNumber == 2
            qw3 = fcnFromString(boundaryConditions[3].qw)
            if boundaryConditions[2].serialNumber == 1
                bt2 = fcnFromString(boundaryConditions[2].bt)
                T[f(1,n,n)] = bt2(t)
            elseif boundaryConditions[2].serialNumber == 2
                qw2 = fcnFromString(boundaryConditions[2].qw)
                dT[f(1,n,n)] = 2*(qw3(t)/dx+qw2(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,n-1,n)]-T[f(1,n,n)])/dx^2+
                2*p[1]*(T[f(2,n,n)]-T[f(1,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[2].serialNumber == 3
                dT[f(1,n,n)] = 2*(qw3(t)/dx+p[5]*(Tf2(t)-T[f(1,n,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,n-1,n)]-T[f(1,n,n)])/dx^2+
                2*p[i]*(T[f(2,n,n)]-T[f(1,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
            if boundaryConditions[4].serialNumber == 1
                bt4 = fcnFromString(boundaryConditions[4].bt)
                T[f(m,n,n)] = bt4(t)
            elseif boundaryConditions[4].serialNumber == 2
                qw2 = fcnFromString(boundaryConditions[4].qw)    
                dT[f(m,n,n)] = 2*(qw3(t)/dx+qw2(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,n-1,n)]-T[f(m,n,n)])/dx^2+
                2*p[1]*(T[f(m-1,n,n)]-T[f(m,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[4].serialNumber == 3
                dT[f(m,n,n)] = 2*(qw3(t)/dx+p[7]*(Tf4(t)-T[f(m,n,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,n-1,n)]-T[f(m,n,n)])/dx^2+
                2*p[1]*(T[f(m-1,n,n)]-T[f(m,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        elseif boundaryConditions[3].serialNumber == 3
            if boundaryConditions[2].serialNumber == 1
                bt2 = fcnFromString(boundaryConditions[2].bt)
                T[f(1,n,n)] = bt2(t)
            elseif boundaryConditions[2].serialNumber == 2
                qw2 = fcnFromString(boundaryConditions[2].qw)
                dT[f(1,n,n)] = 2*(p[6]*(Tf3(t)-T[f(1,n,n)])/dx+qw2(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,n-1,n)]-T[f(1,n,n)])/dx^2+
                2*p[1]*(T[f(2,n,n)]-T[f(1,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[2].serialNumber == 3
                dT[f(1,n,n)] = 2*(p[6]*(Tf3(t)-T[f(1,n,n)])/dx+p[5]*(Tf2(t)-T[f(1,n,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(1,n-1,n)]-T[f(1,n,n)])/dx^2+
                2*p[1]*(T[f(2,n,n)]-T[f(1,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
            if boundaryConditions[4].serialNumber == 1
                bt4 = fcnFromString(boundaryConditions[4].bt)
                T[f(m,n,n)] = bt4(t)
            elseif boundaryConditions[4].serialNumber == 2
                qw4 = fcnFromString(boundaryConditions[4].qw)
                dT[f(m,n,n)] = 2*(p[6]*(Tf3(t)-T[f(m,n,n)])/dx+qw4(t)/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,n-1,n)]-T[f(m,n,n)])/dx^2+
                2*p[1]*(T[f(m-1,n,n)]-T[f(m,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            elseif boundaryConditions[4].serialNumber == 3
                dT[f(m,n,n)] = 2*(p[6]*(Tf3(t)-T[f(m,n,n)])/dx+p[7]*(Tf4(t)-T[f(m,n,n)])/dy)/(p[2]*p[3])+
                2*p[1]*(T[f(m,n-1,n)]-T[f(m,n,n)])/dx^2+
                2*p[1]*(T[f(m-1,n,n)]-T[f(m,n,n)])/dy^2+
                internalHeatSource(t)/(p[2]*p[3])
            end
        end
    end
    #5.利用DifferentialEquations求解
    prob = ODEProblem(heat!, u0, (0, time), p, saveat=1)
    sol = solve(prob, Tsit5())
    #6.数值解的规范化
    an_len = length(sol.u)
    res = zeros(m, n, an_len)
    for t in 1:an_len
        for i in 1:m
            for j in 1:n
                res[i, j, t] = sol.u[t][f(i, j, n)]
            end
        end
    end
    #7.结束
    return res
end
