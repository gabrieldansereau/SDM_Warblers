using DataFrames
using SimpleSDMLayers

# Select climate variables
var_names = (:temperature, :precipitation)
wc_vars = [worldclim(i, resolution="2.5") for i in (1,12)]

# Extract variable dimensions
grid_size_lat = size(wc_vars[1].grid)[1]
grid_size_long = size(wc_vars[1].grid)[2]
grid_size_total = length(wc_vars[1].grid)

# Determine ratio array cells per lat/long degree
grid_ratio = grid_size_lat/(2*90)
grid_ratio == grid_size_long/(2*180) # must be true

# Create dataframe for keep observations
clim = DataFrame()

# Coordinates range
lats = collect(wc_vars[1].bottom:1/grid_ratio:(wc_vars[1].top-1/grid_ratio))
longs = collect(wc_vars[1].left:1/grid_ratio:(wc_vars[1].right-1/grid_ratio))

# Fill df with coordinates
clim.latitude = repeat(lats, outer = grid_size_long)
clim.longitude = repeat(longs, inner = grid_size_lat)

# Extract climate data
for i in 1:length(wc_vars)
    clim[var_names[i]] = vec(wc_vars[i].grid)
end
clim
