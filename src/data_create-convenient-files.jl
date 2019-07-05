### Create Convenient CSV Files

using CSV
using DataFrames
using SimpleSDMLayers

## Quebec 2018 observations (smaller csv file)
# Select 2018 observations
warblers_qc = CSV.read("../data/warblers_qc.csv", header=true, delim="\t")
warblers_2018 = warblers_qc[warblers_qc.year .=== 2018, :]
# Write to CSV
CSV.write("../data/warblers_qc_2018.csv", warblers_2018, delim="\t")
# Test CSV file
test = CSV.read("../data/warblers_qc_2018.csv", header=true, delim="\t")
first(test, 6)
names(test)

## Mtl environment dataframe
# Load functions
include("explo_functions.jl")
# Load warbler data
warblers_mtl = CSV.read("../data/warblers_mtl.csv", header=true, delim="\t")
# Select climate variables
var_names = (:temperature, :precipitation)
resolution = 2.5
wc_vars = [worldclim(i, resolution="$(resolution)") for i in (1,12)]
# Prepare data
df = prepare_csvdata(warblers_mtl)
grid_size = resolution/60
occ = obs_to_occ(df)
# Crop variables to selected region
wc_vars_occ = SimpleSDMPredictor{Float64,Float64}[]
for i in 1:length(wc_vars)
    push!(wc_vars_occ, wc_vars[i][(minimum(longitudes(occ)), maximum(longitudes(occ))),
                                  (minimum(latitudes(occ)), maximum(latitudes(occ)))])
end
# Convert to dataframe
mtl_env = wc_vars_df(wc_vars_occ, names)
# Write to CSV
CSV.write("../data/mtl_env.csv", mtl_env, delim="\t")
# Test CSV file
test = CSV.read("../data/mtl_env.csv", header=true, delim="\t")

## Mtl sites x species dataframe
# Create sites x species matrix
sites_x_species = sitesXspecies(df)
# Write to CSV
CSV.write("../data/mtl_spe.csv", sites_x_species, delim="\t")
# Test CSV
test = CSV.read("../data/mtl_spe.csv")
