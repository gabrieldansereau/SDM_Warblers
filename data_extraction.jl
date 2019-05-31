using GBIF
using Test

# Information on given taxon
parulidae = taxon("Parulidae", rank=:FAMILY)

# Retrieving latest occurrences
occurrences()

#
test = occurrence(2179568203)
occurrences(parulidae::GBIFTaxon)

# From GBIF test scripts on GitHub
qpars = Dict("scientificName" => "Mus musculus", "year" => 1999, "hasCoordinate" => true)
set = occurrences(qpars)
@test typeof(set) == GBIFRecords
@test length(set) == 20

# From GitLab https://gitlab.com/tpoisot/BioClim/blob/master/community.jl
function gbifdata(sp)
    @info sp
    q = Dict{Any,Any}("limit" => 200, "country" => "CA")
    occ = occurrences(sp, q)
    [next!(occ) for i in 1:29]
    qualitycontrol!(occ; filters=[have_ok_coordinates, have_both_coordinates])
    return occ
end

parulidae = taxon("Parulidae"; strict=false)
parulidae_latest_200 = occurrences(parulidae, Dict("limit"=>200, "country"=>"CA"))
canadian_warblers = unique([p.taxon for p in parulidae_latest_200])

warblers_occ = gbifdata.(canadian_warblers)
lon_range = (-136.0, -58.0)
lat_range = (40.5, 56.0)
