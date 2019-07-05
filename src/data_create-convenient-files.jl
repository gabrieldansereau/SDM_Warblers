### Create Convenient CSV Files

using CSV

## Quebec 2018 observations (smaller csv file)

# Select 2018 observations
warblers = CSV.read("../data/warblers_qc.csv", header=true, delim="\t")
warblers_2018 = warblers[warblers.year .=== 2018, :]
# Write to csv
CSV.write("../data/warblers_qc_2018.csv", warblers_2018, delim="\t")

# Test csv file
test = CSV.read("../data/warblers_qc_2018.csv", header=true, delim="\t")
first(test, 6)
names(test)

## Mtl environment dataframe

# Load functions (takes ~ 90 sec)
include(explo_visualization.jl)

# Select climate variables
var_names = (:temperature, :precipitation)
wc_vars = [worldclim(i, resolution="2.5") for i in (1,12)]
# Crop variables to selected region
wc_vars_occ = SimpleSDMPredictor{Float64,Float64}[]
for i in 1:length(wc_vars)
    push!(wc_vars_occ, wc_vars[i][(minimum(longitudes(occ)), maximum(longitudes(occ))),
                                  (minimum(latitudes(occ)), maximum(latitudes(occ)))])
end
# Convert to dataframe
mtl_env = wc_vars_df(wc_vars_occ, names)
# Write to csv
CSV.write("../data/mtl_env.csv", mtl_env, delim="\t")
# Test csv file
test = CSV.read("../data/mtl_env.csv", header=true, delim="\t")
