using CSV
using DataFrames
using SimpleSDMLayers

## Get data
# Warbler data for Montreal area
warblers = CSV.read("../data/warblers_mtl.csv", header=true, delim="\t")
# Warbler data for Quebec in 2018
# warblers = CSV.read("../data/warblers_qc_2018.csv", header=true, delim="\t")
# Bioclim layers
resolution = 2.5 # useful to keep as variable
temperature, precipitation = worldclim([1,12], resolution="$(resolution)")

## Prepare data
function prepare_csvdata(csvdata::DataFrame)
    # Subset with specific columns
    df = csvdata[:, [:species, :year, :decimalLatitude, :decimalLongitude]]
    # Rename coordinate columns names
    rename!(df, :decimalLatitude => :latitude)
    rename!(df, :decimalLongitude => :longitude)
    # Replace spaces by underscores in species names
    df.species .= replace.(df.species, " " .=> "_")
    # Remove entries with missing year
    dropmissing!(df, :year)
    return df
end
df = prepare_csvdata(warblers)

## Match observations & bioclim data
# Get temperature matching observations
function match_clim_var(df::DataFrame, var::SimpleSDMPredictor{Float64,Float64})
    matched_var = zeros(size(df)[1])
    for i in 1:size(df)[1]
        matched_var[i] = var[df.longitude[i], df.latitude[i]]
    end
    return matched_var
end
# Bind bioclim data to observation dataframe
df.temperature = match_clim_var(df, temperature)
df.precipitation = match_clim_var(df, precipitation)
df

## Create occurence array with correct dimensions
# Determine grid size required to match coordinates
grid_size = resolution/60 # because of resolution = arcmin degrees?
# Create useful conversion functions
function round_coord(coord::Float64)
    round((coord-grid_size/2)/grid_size)*grid_size+grid_size/2
end
function lat_to_grid(lat::Float64)
    Int64(floor((lat+90)/grid_size))
end
function long_to_grid(long::Float64)
    Int64(floor((long+90)/grid_size))
end
# Create occurence array
function obs_to_occ(df::DataFrame)
    # Round coordinates
    longs = round_coord.(df.longitude)
    lats = round_coord.(df.latitude)
    # Determine coordinates range
    long_range = minimum(longs):grid_size:maximum(longs)
    lat_range = minimum(lats):grid_size:maximum(lats)
    # Create empty arrays
    longs_grid = zeros(Int64, length(df.species))
    lats_grid = zeros(Int64, length(df.species))
    occ = zeros(Int64, length(lat_range), length(long_range))
    # Convert observations to occurences
    long_min = long_to_grid(minimum(longs))
    lat_min = lat_to_grid(minimum(lats))
    for i in 1:length(df.species)
        # Convert coordinates to array position
        longs_grid[i] = long_to_grid(longs[i])-long_min+1
        lats_grid[i] = lat_to_grid(lats[i])-lat_min+1
        # Compile occurences
        occ[lats_grid[i], longs_grid[i]] += 1
    end
    # Convert to SDMLayer
    occ_SDMLayer = SimpleSDMPredictor(occ,
                              minimum(longs),
                              maximum(longs),
                              minimum(lats),
                              maximum(lats))
    return occ_SDMLayer
end
occ = obs_to_occ(df)

## Sites with >1 observation (binary)
function obs_as_bin(obs)
    obs_copy = deepcopy(obs)
    obs_copy.grid[obs_copy.grid .> 0] .= 1.0
    return obs_copy
end
occ_bin = obs_as_bin(occ)
map_occ_bin = heatmap(occ_bin.grid)

# ## Number of species
# # List species per site (with "NA", could not find another way)
# species_per_site = fill(String["NA"], size(occ.grid)[1], size(occ.grid)[2])
# for i in 1:length(df.species)
#     if (df.species[i] in species_per_site[lats[i], longs[i]]) == false
#         species_per_site[lats[i], longs[i]] = vec(vcat(species_per_site[lats[i], longs[i]], df.species[i]))
#     end
# end
# # Crop to observed sites
# species_per_site_obs = species_per_site[(minimum(lats):maximum(lats)),(minimum(longs):maximum(longs))]
# # Count species per site
# species_counts = length.(species_per_site_obs) .- 1

## Ecological data matrix
function sitesXspecies(df::DataFrame)
    # List species in dataset
    species_list = unique(df.species)
    # Keep lats & longs separated
    lats = round_coord.(df.latitude)
    longs = round_coord.(df.longitude)
    # Create coordinates & occurences parts of ecological data matrix
    sites_x_species_coord = DataFrame()
    sites_x_species_occ = zeros(Int64,
                                length(unique(lats))*length(unique(longs)),
                                length(species_list))
    # Add latitude & longitude to dataset
    sites_x_species_coord.latitude = repeat(minimum(lats):grid_size:maximum(lats),
                                            outer=length(unique(longs)))
    sites_x_species_coord.longitude = repeat(minimum(longs):grid_size:maximum(longs),
                                             inner=length(unique(lats)))
    # Fill in sites x species occurence dataframe
    for i in 1:length(df.species)
        rows_lats = findall(x -> x == lats[i], sites_x_species_coord.latitude)
        rows_longs = findall(x -> x == longs[i], sites_x_species_coord.longitude)
        row = intersect(rows_lats, rows_longs)[1]
        col = findfirst(x -> x == df.species[i], species_list)
        sites_x_species_occ[row, col] += 1
    end
    sites_x_species_occ = DataFrame(sites_x_species_occ)
    # Rename columns by species names
    names!(sites_x_species_occ, Symbol.(species_list))
    # Create full ecological data matrix
    sites_x_species = hcat(sites_x_species_coord, sites_x_species_occ)
    return sites_x_species
end
sites_x_species = sitesXspecies(df)
