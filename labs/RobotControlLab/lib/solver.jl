using OptControl, Symbolics
using Statistics, LinearAlgebra

function solver(_t0, _tf, timespan, model="最省距离", N=200)

    function initPara()
        J1 = 1.0 / 12 * collect(I(3))
        C1 = 0.5 * [1 2 2; 0 1 2; 0 0 2]
        D1 = 0.5 * [1 0 0; 2 1 0; 4 2 1]
        J = J1 + C1 * D1
        K = 0.5 * [5 0 0; 0 3 0; 0 0 1]
        B = [1 -1 0; 0 1 -1; 0 0 1]
        A = inv(J) * K
        B = inv(J) * B
        return A, B
    end
    A, B = initPara()
    zs = fill(0.0, 3, 3)
    A = vcat(hcat(zs, 1.0 * collect(I(3))), hcat(A, zs))
    B = vcat(zs, B)

    @variables u[1:3] x[1:6]
    f = A * x + B * u
    if model == "最短距离"
        L = Symbolics.scalarize(sum(x -> x^2, x))
    else
        L = Symbolics.scalarize(sum(x -> x^2, u))
    end
    t0 = push!(_t0, zeros(3)...)
    tf = push!(_tf, zeros(3)...)
    tspan = (0.0, timespan)
    sub = [pi / 2, pi / 2, pi / 2, Inf, Inf, Inf]
    slb = -sub
    return generateJuMPcodes(L, f, x, u, tspan, t0, tf, N=N, state_ub=sub, state_lb=slb,)
end


# sol = solver([π / 3, -π / 4, π / 2], [-π / 3, π / 4, -π / 5], 1.5) # test



# degrees = real.(sol[:, 1:3])
# velocity = real.(sol[:, 4:6])

# using Plots
# filename = "./a.gif"
# anim = @animate for i in 1:N
#     l = collect(0:0.01:1)
#     xs1 = l .* sin(degrees[i][1])
#     ys1 = l .* cos(degrees[i][1])
#     xs2 = l .* sin(degrees[i][2]) .+ xs1[end]
#     ys2 = l .* cos(degrees[i][2]) .+ ys1[end]
#     xs3 = l .* sin(degrees[i][3]) .+ xs2[end]
#     ys3 = l .* cos(degrees[i][3]) .+ ys2[end]
#     plot([xs1, xs2, xs3], [ys1, ys2, ys3],
#         ylims=(0, 4), xlims=(-3, 3), w=3,
#         grid=false, showaxis=false, legend=false)
# end
# gif(anim, filename, fps=24)