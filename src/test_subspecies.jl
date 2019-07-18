using CSV
using DataFrames

warblers = CSV.read("../data/warblers_qc.csv", header=true, delim="\t")

df = warblers[:, [:species, :infraspecificEpithet,:taxonRank, :scientificName]]
dropmissing!(df, :species)

# Check possile taxon ranks
unique(df.taxonRank)
# Check subspecies observations
df[df.taxonRank .=== "SUBSPECIES",:]

# Add subspecies to species name
df.newspecies = copy(df.species)
for i in 1:length(df.species)
    if df.taxonRank[i] == "SUBSPECIES"
        df.newspecies[i] = string(df.species[i], " ", df.infraspecificEpithet[i])
    end
end
# Show result for subspecies observations
show(df[df.taxonRank .== "SUBSPECIES", [:species, :infraspecificEpithet, :newspecies]], allrows=true)

# Get number of observatons per species/subspecies
newdf = by(df, :newspecies, n = :newspecies => length)
show(sort(newdf, order(:newspecies)), allrows=true)
