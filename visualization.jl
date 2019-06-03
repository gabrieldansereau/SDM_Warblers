using CSV
# using DataFrames
# using JuliaDB

CSV.read("../data/warblers_mtl.csv", header=false, delim="\t")

using SimpleSDMLayers

temperature, precipitation = worldclim([1,12])
