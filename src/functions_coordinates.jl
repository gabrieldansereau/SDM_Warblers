# Custom functions for conversion from coordinate to grid position
function conv_lat(lat, grid_ratio)
    Int64(round((lat+90)*grid_ratio))
end
function conv_long(long, grid_ratio)
    Int64(round((long+180)*grid_ratio))
end

# Custom functions to round coordinates
function coord_floor(coord)
    floor(coord*grid_ratio)/grid_ratio
end
function coord_ceil(coord)
    ceil(coord*grid_ratio)/grid_ratio
end
function coord_round(coord)
    round(coord*grid_ratio)/grid_ratio
end
function coord_range(coords, grid_ratio)
    coord_floor(minimum(coords)):1/grid_ratio:coord_ceil(maximum(coords))
end
