#### Scraps ####

## Visualize data
# Dataframe names
names(warblers)
# First entries (~head)
first(df,6)
# Show all columns
show(first(df,6), allcols=true)
# Describe columns (~summary)
show(describe(df), allcols=true)
# Select on conditions (year)
df_full = dropmissing(df, :year)
df_full[df_full.year .< 1900, :]
# Record from 1700 ???
show(warblers[warblers.year .=== 1700, :], allcols=true)

#######################################################
#### Exploration

## Understand data structure
# Find resolution & digits concordance
res = zeros(10,10)
for i in 1:10, j in 1:10
    res[i,j] = i |> x ->
        temperature[round(df.longitude[j], digits=x),
                    round(df.latitude[j], digits=x)]
end
res # 3 digit seem necessary

# Explore temperature array
temperature.grid
temperature.grid[1,1]
temperature[-180.0, -90.0]
# first element has coordinates -180.0, -90.0

# Test conversion from coordinate to grid position
conv_lat(df.latitude[1], grid_ratio)
conv_lat(-90, grid_ratio)
conv_lat(-89, grid_ratio)
conv_lat(89.1, grid_ratio)
conv_lat(90, grid_ratio)
conv_long(df.longitude[1], grid_ratio)
