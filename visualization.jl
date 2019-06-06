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

# Get temperature matching observations
temperature[df.decimalLongitude[1], df.decimalLatitude[1]]
temp_warblers = zeros(length(df.decimalLatitude))
for i in 1:length(df.decimalLatitude)
    temp_warblers[i] = temperature[df.decimalLongitude[i], df.decimalLatitude[i]]
end

# Bind temperatures to observation dataframe
df.temperature = temp_warblers
df
show(df, allcols=true)

temperature

# Find resolution & digits concordance
res = zeros(10,10)
for i in 1:10, j in 1:10
    res[i,j] = i |> x -> temperature[round(df.decimalLongitude[j], digits=x), round(df.decimalLatitude[j], digits=x)]
end
res

temperature.grid
temperature.grid[1,1]

typeof(-180.0)

occ = zeros(AbstractFloat,size(temperature.grid))
occSDM = SimpleSDMPredictor.(occ, -180.0::AbstractFloat, 180.0::AbstractFloat, -90.0::AbstractFloat, 90.0::AbstractFloat)
occ.grid = zeros(size(occ.grid))
occ = zeros(temperature)

temperature.grid[1,1]
temperature[-180.0, -90.0]
