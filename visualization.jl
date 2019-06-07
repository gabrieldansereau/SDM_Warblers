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

## Observations in array with correction dimensions
# Verification
Int64(round((df.decimalLatitude[1]+90)*6))
round((-90+90)*6)
round((-89+90)*6)
round((89.1+90)*6)
round((90+90)*6)
round((df.decimalLongitude[1]+180)*6)

# Custom functions
function round_lat(lat)
    Int64(round((lat+90)*6))
end
function round_lon(lon)
    Int64(round((lon+180)*6))
end

# Create occurence array
occ = zeros(size(temperature.grid))
lats = zeros(Int64, length(df.species))
lons = zeros(Int64, length(df.species))
for i in 1:length(df.species)
    lats[i] = round_lat(df.decimalLatitude[i])
    lons[i] = round_lat(df.decimalLongitude[i])
    occ[lats[i], lons[i]] += 1
end
occ
occ_obs = occ[(minimum(lats):maximum(lats)),(minimum(lons):maximum(lons))]

using Plots
heatmap(occ_obs)
heatmap(minimum(lats):0.166667:maximum(lats), minimum(lons):0.166667:maximum(lons), occ)
heatmap(minimum(lats):0.166667:maximum(lats), minimum(lons):0.166667:maximum(lons), temperature.grid)
heatmap(minimum(df.decimalLongitude):0.166667:maximum(df.decimalLongitude),
        minimum(df.decimalLatitude):0.166667:maximum(df.decimalLatitude),
        occ_obs)
heatmap(-180:0.166667:180, -90:0.166667:90, occ)

SimpleSDMLayer.(occ, -180.0, 180.0, -90.0, 90.0)
test.grid = occ_obs
