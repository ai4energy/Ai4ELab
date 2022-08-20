using CSV
using DataFrames

file = CSV.File("Backend_Upload/data.csv") |> DataFrame

names(file)

file[!,Symbol(names(file)[2])]