using JuMP, NLopt, NonlinearSolve

function Parameter_fitting(V_DATA::Vector{Float64},I_DATA::Vector{Float64})
    V=V_DATA
    I=I_DATA
    N=length(V)
    num=5
    T0=300
    k=1.38e-23
    q=1.6e-19

    model = Model(NLopt.Optimizer)
    set_optimizer_attribute(model, "algorithm", :AUGLAG)
    local_optimizer = NLopt.Opt(:LD_LBFGS, num)
    local_optimizer.xtol_rel = 1e-10
    set_optimizer_attribute(model, "local_optimizer", local_optimizer)

    @variable(model,x[1:num])
    Iph=x[1]
    Io=x[2]*1.0e-6
    n=x[3]
    Rs=x[4]
    Rsh=x[5]

    set_start_value(x[1], 0.1)
    set_start_value(x[2], 0.1)
    set_start_value(x[3], 1.0)
    set_start_value(x[4], 0.01)
    set_start_value(x[5], 2.1)

    @constraint(model, x[1] >= 0.1)
    @constraint(model, x[1] <= 10)
    # @constraint(model, x[2] >= 0.1)
    # @constraint(model, x[2] <= 0.325)
    @constraint(model, x[3] >= 1.0)
    @constraint(model, x[3] <= 2.)
    @constraint(model, x[4] >= 0.001)
    @constraint(model, x[4] <= 0.01)
    @constraint(model, x[5] >= 3.0)
    @constraint(model, x[5] <= 100.0)
    @NLexpression(model, L[i=1:N], (Iph-Io*(exp(q*(V[i]+I[i]*Rs)/n/k/T0)-1)-(V[i]+I[i]*Rs)/Rsh-I[i])^2)
    @NLexpression(model, Loss, sqrt((sum(L[i] for i in 1:N))/N));

    @NLobjective(model, Min, Loss)
    JuMP.optimize!(model)

    Iph=JuMP.value.(x[1])
    Io=JuMP.value.(x[2])*1.0e-6
    n=JuMP.value.(x[3])
    Rs=JuMP.value.(x[4])
    Rsh=JuMP.value.(x[5])

    #Compute fitting data
    comput_I=zeros(N)
    f(I0,V0) = Iph-Io*(exp(q*(V0+I0*Rs)/n/k/T0)-1)-(V0+I0*Rs)/Rsh-I0
    I0=0.5
    for i in 1:N
        V0=V[i]
        probN = NonlinearProblem{false}(f, I0,V0)
        solver = solve(probN, NewtonRaphson(), tol = 1e-9)
        comput_I[i]=solver.u
    end

    return Iph,Io,n,Rs,Rsh,comput_I
end