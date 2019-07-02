using CSV
using DataFrames
using SimpleSDMLayers
using Plots

# Source function script for coordinates
include("functions_coordinates.jl")

## Get data
# Warbler data (CSV)
warblers = CSV.read("../data/warblers_mtl.csv", header=true, delim="\t")
warblers = CSV.read("../data/warblers_qc_2018.csv", header=true, delim="\t")
# Bioclim layers
temperature, precipitation = worldclim([1,12], resolution="2.5")

## Visualize data
# Dataframe names
names(warblers)
# Subset with specific columns
df = warblers[:, [:species, :year, :decimalLatitude, :decimalLongitude]]
# First entries (~head)
first(df,6)
# Show all columns
show(first(df,6), allcols=true)
# Describe columns (~summary)
show(describe(df), allcols=true)
# Select on conditions (year)
df_full = dropmissing(df, :year)
df_full[df_full.year .< 1900, :]
# Record from 1700 ???
show(warblers[warblers.year .=== 1700, :], allcols=true)

## Match observations & bioclim data
# Test syntax
temperature[df.decimalLongitude[1], df.decimalLatitude[1]]
# Get temperature matching observations
temp_warblers = zeros(length(df.decimalLatitude))
for i in 1:length(df.decimalLatitude)
    temp_warblers[i] = temperature[df.decimalLongitude[i], df.decimalLatitude[i]]
end
# Bind temperatures to observation dataframe
df.temperature = temp_warblers
# View matched data
show(df, allcols=true)

## Create occurence array with correct dimensions
size(temperature.grid) # [1] is lat, [2] is long
# Ratio array cells per lat/long degree
grid_ratio = size(temperature.grid)[1]/(2*90)
grid_ratio == size(temperature.grid)[2]/(2*180) # must be true
# Create occurence array
occ = zeros(size(temperature.grid))
lats = zeros(Int64, length(df.species))
longs = zeros(Int64, length(df.species))
for i in 1:length(df.species)
    lats[i] = conv_lat(df.decimalLatitude[i], grid_ratio)
    longs[i] = conv_long(df.decimalLongitude[i], grid_ratio)
    occ[lats[i], longs[i]] += 1
end
# Crop to selected region
occ_obs = occ[(minimum(lats):maximum(lats)),(minimum(longs):maximum(longs))]

## Map occurences
# Map occurences
map_occ = heatmap(occ_obs)
# Map with coordinates
map_occ_coord = heatmap(coord_range(df.decimalLongitude, grid_ratio),
                        coord_range(df.decimalLatitude, grid_ratio),
                        occ_obs)
# Map temperature for same coordinates
map_temp = temperature[(minimum(df.decimalLongitude), maximum(df.decimalLongitude)),
                        (minimum(df.decimalLatitude), maximum(df.decimalLatitude))] |> x ->
                        heatmap(x.grid)

## Sites with >1 observation (binary)
occ_obs_bin = occ_obs
occ_obs_bin[occ_obs_bin .> 0] .= 1.0
occ_obs_bin
map_occ_bin = heatmap(occ_obs_bin)

## Number of species
# List species per site (with "NA", could not find another way)
species_per_site = fill(String["NA"], size(temperature.grid)[1], size(temperature.grid)[2])
for i in 1:length(df.species)
    if (df.species[i] in species_per_site[lats[i], longs[i]]) == false
        species_per_site[lats[i], longs[i]] = vec(vcat(species_per_site[lats[i], longs[i]], df.species[i]))
    end
end
# Crop to observed sites
species_per_site_obs = species_per_site[(minimum(lats):maximum(lats)),(minimum(longs):maximum(longs))]
# Count species per site
species_counts = length.(species_per_site_obs) .- 1
# Map species per site
map_species_count = heatmap(species_counts)
map_occ_per_species = heatmap(occ_obs./species_counts)

## Ecological data matrix
# Replace spaces by underscores
df.species .= replace.(df.species, " " .=> "_")
# List species in dataset
species_list = unique(df.species)
# Create coordinates & occurences parts of ecological data matrix
sites_x_species_coord = DataFrame()
sites_x_species_occ = zeros(Int64, (length(occ_obs), length(species_list)))
# Add latitude & longitude to dataset
sites_x_species_coord.latitude = repeat(coord_range(df.decimalLatitude, grid_ratio), outer=size(occ_obs)[2])
sites_x_species_coord.longitude = repeat(coord_range(df.decimalLongitude, grid_ratio), inner=size(occ_obs)[1])
# Fill in sites x species occurence dataframe
for i in 1:length(df.species)
    possib_x = findall(x -> x == coord_round(df.decimalLatitude[i], grid_ratio), sites_x_species_coord.latitude)
    possib_y = findall(y -> y == coord_round(df.decimalLongitude[i], grid_ratio), sites_x_species_coord.longitude)
    row = possib_y[findfirst(in(possib_x), possib_y)]
    col = findfirst(x -> x == df.species[i], species_list)
    sites_x_species_occ[row, col] += 1
end
sites_x_species_occ = DataFrame(sites_x_species_occ)
# Rename columns by species names
names!(sites_x_species_occ, Symbol.(species_list))
# Create full ecological data matrix
sites_x_species = hcat(sites_x_species_coord, sites_x_species_occ)
# Plot single species occurences
map_single_sp1 = heatmap(reshape(Array(sites_x_species.Setophaga_caerulescens), 11, 18))

## Heatmaps for all species (single species per heatmap)
# Option 1: using array of plots, produce plot combining multiple single-species plots
plot_array = Any[]
# 9 species at time, result is ok
for i in 1:9
    push!(plot_array,
          heatmap(reshape(Array(sites_x_species[Symbol(species_list[i])]), 11, 18),
                  title=species_list[i]))
end
map_single_sp_9x = plot(plot_array..., size=(1800,900), aspect_ratio=:equal)

# Option 2: using @eval, produce each species heatmap as 1 element in workspace
for i in 1:length(species_list)
    global j = i
    @eval $(Symbol(string("map_single_sp_", species_list[j]))) = heatmap(reshape(Array(sites_x_species[Symbol(species_list[j])]), 11, 18))
end

# Option 3: using Dict, produce each heatmap as element in dictionnary
species_maps = Dict(Symbol(species_list[i]) =>
                    heatmap(reshape(Array(sites_x_species[Symbol(species_list[i])]), 11, 18))
                    for i=1:length(species_list))
species_maps[Symbol(species_list[1])]
# Produce all graphs
for i in 1:length(species_list)
    display(species_maps[Symbol(species_list[i])])
end
# useless @eval plot($(Symbol.(string.("map_single_sp_", species_list))))

mtl_layer = geotiff.("./assets/mtl.tif")

## Export figures
savefig(map_occ, "fig/map-occurences")
savefig(map_occ_coord, "fig/map-occurences-with-coordinates")
savefig(map_temp, "fig/map-temperature")
savefig(map_occ_bin, "fig/map-occurences-binary-qc")
savefig(map_species_count, "fig/map-species-count")
savefig(map_occ_per_species, "fig/map-occurences-per-species")
savefig(map_single_sp1, "fig/map-single-species-example")
savefig(map_single_sp_9x, "fig/map-single-species-9x.png")


#######################################################
#### Exploration

## Understand data structure
# Find resolution & digits concordance
res = zeros(10,10)
for i in 1:10, j in 1:10
    res[i,j] = i |> x ->
        temperature[round(df.decimalLongitude[j], digits=x),
                    round(df.decimalLatitude[j], digits=x)]
end
res # 3 digit seem necessary

# Explore temperature array
temperature.grid
temperature.grid[1,1]
temperature[-180.0, -90.0]
# first element has coordinates -180.0, -90.0

# Test conversion from coordinate to grid position
conv_lat(df.decimalLatitude[1], grid_ratio)
conv_lat(-90, grid_ratio)
conv_lat(-89, grid_ratio)
conv_lat(89.1, grid_ratio)
conv_lat(90, grid_ratio)
conv_long(df.decimalLongitude[1], grid_ratio)
