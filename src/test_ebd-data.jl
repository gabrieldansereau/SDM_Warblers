using CSV
using DataFrames

ebd = CSV.read("/home/gdansereau/Downloads/ebd_sample/ebd_sample.txt", delim="\t")

newnames = string.(names(ebd))
newnames = Symbol.(replace.(newnames, " " .=> "_"))
names!(ebd, newnames)

show(ebd, allcols=true)

by(ebd, :PROTOCOL_TYPE, :PROTOCOL_TYPE => length)
by(ebd, :ALL_SPECIES_REPORTED, :ALL_SPECIES_REPORTED => length)
