using DataFrames
using SimpleSDMLayers

# Select climate variables
var_names = (:temperature, :precipitation)
wc_vars = [worldclim(i, resolution="2.5") for i in (1,12)]

function wc_vars_df(vars, names)
    # Extract array dimensions
    grid_size_lat = size(vars[1], 1)
    grid_size_long = size(vars[1], 2)

    # Create dataframe to keep observations
    clim = DataFrame()

    # Coordinates range
    lats = collect(latitudes(vars[1]))
    longs = collect(longitudes(vars[1]))

    # Fill df with coordinates
    clim.latitude = repeat(lats, outer = grid_size_long)
    clim.longitude = repeat(longs, inner = grid_size_lat)

    # Extract climate data
    for i in 1:length(vars)
        clim[var_names[i]] = vec(vars[i].grid)
    end

    return clim
end
wc_vars_df(wc_vars, var_names)
