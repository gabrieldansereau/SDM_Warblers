using Pkg
Pkg.add https://github.com/EcoJulia/SimpleSDMLayers.jl#master
Pkg.add Plots
using SimpleSDMLayers
using Plots
temperature, precipitation = worldclim([1,12])
temperature
temperature.grid
temperature.left
temperature.right
temperature.top
temperature.bottom
temperature[47.0, -12.0]
heatmap(temperature.grid)
temperature[800, 500]
heatmap(longitudes(temperature), latitudes(temperature), temperature.grid)
temperature[-100.0, 30.0]
precipitations[-100.0, 30.0]
precipitation[-100.0, 30.0]
temperature[(-160.0, -50.0), (0.0, 90.0)]
temperature[(-160.0, -50.0), (0.0, 90.0)] |> x -> heatmap(x.grid)
temp_NA = temperature[(-160.0, -50.0), (0.0, 90.0)]
precipitation[temp_NA]
precipitation[temp_NA] |> x -> heatmap(x.grid)
