using CSV
using DataFrames

include("../../BioClim/src/required.jl")

ebd = CSV.read("../data/ebd/ebd_warblers_cut.csv", delim="\t")
gbif = CSV.read("../data/warblers_cut.csv", delim="\t")

#=
newnames = names(ebd) .|>
    string .|>
    titlecase .|>
    lowercasefirst .|>
    x -> replace(x, " " => "") .|>
    Symbol
names!(ebd, newnames)
=#
df = prepare_ebd_data(ebd)

show(ebd, allcols=true)

by(ebd, :protocolType, :protocolType => length)
by(ebd, :allSpeciesReported, n = :allSpeciesReported => length)
@time by(ebd, :countryCode, nrow) # slower but easier to write
@time by(ebd, :countryCode, :countryCode => length) # faster
@time by(ebd, :scientificName, nrow)
@time by(ebd, :scientificName, :scientificName => length)
first(sort(by(ebd, :scientificName, nrow), :x1, rev=true), 10)
first(sort(by(gbif, :species, nrow), :x1, rev=true), 10)
