using SimpleSDMLayers
using Plots
# Get bioclim variables
temperature, precipitation = worldclim([1,12])
temperature
temperature.grid
temperature.left
temperature.right
temperature.top
temperature.bottom
temperature[47.0, -12.0]

# Global heatmap
heatmap(temperature.grid)
temperature[800, 500]
# No heat values in oceans

# Heatmap with longitudes & latitudes
longitudes(temperature)
heatmap(longitudes(temperature), latitudes(temperature), temperature.grid)
temperature[-100.0, 30.0]
precipitation[-100.0, 30.0]

# Restrict latitudes to NA
temperature[(-160.0, -50.0), (0.0, 90.0)]
temperature[(-160.0, -50.0), (0.0, 90.0)] |> x -> heatmap(x.grid)
temp_NA = temperature[(-160.0, -50.0), (0.0, 90.0)]

# Plot precipitations according to precipitation grid
precipitation[temp_NA]
precipitation[temp_NA] |> x -> heatmap(x.grid)
precipitation[temperature] |> x -> heatmap(x.grid)
