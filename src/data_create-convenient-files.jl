### Create Convenient CSV Files

using CSV

warblers = CSV.read("../data/warblers_qc.csv", header=true, delim="\t")
warblers_2018 = warblers[warblers.year .=== 2018, :]
CSV.write("../data/warblers_qc_2018.csv", warblers_2018, delim="\t")

test = CSV.read("../data/warblers_qc_2018.csv", header=true, delim="\t")
first(test, 6)

names(test)
