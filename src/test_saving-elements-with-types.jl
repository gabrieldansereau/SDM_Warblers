using Plots
using GDAL
using Shapefile
using GBIF
using StatsBase
using Statistics

cd("$(homedir())/github/BioClim/")
include("lib/SDMLayer.jl")
include("lib/gdal.jl")
include("lib/worldclim.jl")
include("lib/bioclim.jl")
include("lib/shapefiles.jl")

## How to save

using JLD2
using FileIO
@save "../data/warblers_gbifdata.jld2" warblers_occ
save("../data/warblers_gbifdata.jld2","warblers_occ", warblers_occ)

using BSON
bson("../data/test.bson", Dict(:warblers_occ => warblers_occ))
write("../data/test.write", warblers_occ)

using Serialization
serialize("../data/test-serialize", warblers_occ)
warblers_occ = deserialize("../data/test-serialize")

## How to load

using JLD2
using FileIO
using Dates
@load "../data/warblers_gbifdata.jld2" warblers_occ
load("../data/warblers_gbifdata.jld2")
f = jldopen("../data/warblers_gbifdata2.jld2", "r")

using BSON
BSON.load("../BioClim/test.bson")

using Serialization
warblers_occ = deserialize("../data/test-serialize")
