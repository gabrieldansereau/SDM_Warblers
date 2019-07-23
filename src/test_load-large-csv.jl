## Option 1: JuliaDB
using JuliaDB
using DelimitedFiles

@time df = loadtable("../data/warblers_qc.csv", delim='\t',
                        datacols=[:gbifID, :year, :species], nastrings=[""],
                        type_detect_rows=400000, spacedelim=false)
@time df2 = loadndsparse("../data/warblers_qc.csv", delim='\t', type_detect_rows=400000)

## Option 2: CSVFiles
using CSVFiles
using DataFrames

@time df = load("../data/warblers_qc.csv", '\t', type_detect_rows=400000)

## Option 1-2: TextParse, used by both JuliaDB & CSVFiles
using TextParse
@time df = csvread("../data/warblers_qc.csv", '\t', type_detect_rows=400000,
                    escapechar=' ')

## Option 3: TableReader
using TableReader
df = readcsv("../data/warblers_qc.csv", delim='\t', chunkbits=0)

## Option 4: CSV
using CSV
@time df_csv = CSV.read("../data/warblers_qc.csv", delim='\t')
# Works, but for smaller file only


####
## Trying to catch the error in the CSV file
# Need to find where "Nortel"_ is

using DataFrames
df_csv_nomiss = dropmissing(df_csv, :publishingOrgKey)
df_csv_nomiss = dropmissing!(df_csv_nomiss, :locality)
describe(df_csv_nomiss.publishingOrgKey)
unique(df_csv_nomiss.publishingOrgKey)

df_csv_nomiss[occursin.("Nortel", df_csv_nomiss.locality),:] |>
    x -> unique(x.locality)
