## Cut warblers.csv columns from commandline

# Choose column names to keep in dataframe
columnnames = [:gbifID, :species, :countryCode, :decimalLatitude, :decimalLongitude, :day, :month, :year]
# Load smaller dataframe to get column indices
using CSV
df = CSV.read("../data/warblers_qc.csv")
# Get index of columns
ind = indexin(columnnames, names(df))
ind = Array{Int64}(ind)
# Check selected columns
show(df[:,ind], allcols=true)

## Bash command to run in terminal
# cut -f1,10,14,17,18,26,27,28 warblers.csv > warblers_cut.csv

#######

### Try -> run bash command from julia
## NOT WORKING -> just run command in terminal with correct inds instead
# Arrange format
inds = "$(ind)"
inds = replace(inds, "[" => "")
inds = replace(inds, "]" => "")
inds = replace(inds, " " => "")
inds

# Create command
cmd = `cut -f$(inds) warblers.csv > warblers_cut.csv`
cd("$(homedir())/github/data")
# Run command
@time run(cmd)

# Test result
newdf = CSV.read("warblers_cut.csv")
