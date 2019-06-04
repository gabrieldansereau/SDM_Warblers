using CSV
using DataFrames
# using JuliaDB
using SimpleSDMLayers
# using Statistics

# Read csv
warblers = CSV.read("../data/warblers_mtl.csv", header=true, delim="\t")
# Dataframe names
names(warblers)
# Specific column
warblers.species
df = warblers[:, [:species, :year, :decimalLatitude, :decimalLongitude]]
df
# First entries (~head)
first(df,6)
# Show all columns
show(first(df,6), allcols=true)
# Describe columns (~summary)
show(describe(df), allcols=true)
# Select on conditions
df_full = dropmissing(df, :year)
df_full[df_full.year .< 1900, :]
show(warblers[warblers.year .=== 1700, :], allcols=true)

# Bioclim layers
temperature, precipitation = worldclim([1,12])
