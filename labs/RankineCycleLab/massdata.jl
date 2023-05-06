struct Mass
	name::String
	hname::String
	temperature_limit::Vector{Float64}
	pressure_limit::Vector{Float64}
	number::Int
end

water=Mass("水","water",[273.06, 647.09],[611.655, 2.2064e+07],1)

Ammonia=Mass("氨气","Ammonia",[196.15, 405.15],[6091.22, 1.1333e+07],2)

mass_list = [water, Ammonia]
