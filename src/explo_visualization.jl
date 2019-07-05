using CSV
using DataFrames
using SimpleSDMLayers

## Load functions to explore data
include("explo_functions.jl")

## Get data
# Warbler data for Montreal area
warblers = CSV.read("../data/warblers_mtl.csv", header=true, delim="\t")
# Warbler data for Quebec in 2018
# warblers = CSV.read("../data/warblers_qc_2018.csv", header=true, delim="\t")
# Bioclim layers
resolution = 2.5 # useful to keep as variable
temperature, precipitation = worldclim([1,12], resolution="$(resolution)")

## Prepare data
df = prepare_csvdata(warblers)

## Match observations & bioclim data
# Bind bioclim data to observation dataframe
df.temperature = match_clim_var(df, temperature)
df.precipitation = match_clim_var(df, precipitation)
df

## Create occurence array with correct dimensions
# Determine grid size required to match coordinates
grid_size = resolution/60 # because of resolution = arcmin degrees?
# Create occurence array
occ = obs_to_occ(df)

## Sites with >1 observation (binary)
occ_bin = obs_as_bin(occ)

# ## Number of species

## Ecological data matrix
sites_x_species = sitesXspecies(df)
