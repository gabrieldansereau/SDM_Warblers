## Trying GDAL
using GDAL

# register formats
GDAL.allregister()
### raster
# Load the dataset
dataset = GDAL.open("./assets/mtl.tif", GDAL.GA_ReadOnly)
# Band
band = GDAL.getrasterband(dataset, 1)

# Matrix
xs = GDAL.getrasterxsize(dataset)
ys = GDAL.getrasterysize(dataset)

bandtype = GDAL.getrasterdatatype(band)

V = zeros(Float64, (xs, ys))

GDAL.rasterio(
    band,
    GDAL.GF_Read,
    0, 0, xs, ys,
    pointer(V),
    xs, ys,
    GDAL.getrasterdatatype(band),
    0, 0
    )

K = zeros(Float64, (ys, xs))
for (i,r) in enumerate(reverse(1:size(V, 2)))
    K[i,:] = V[:,r]
end

this_min = minimum(V)

for i in eachindex(K)
    K[i] = K[i] > this_min ? K[i] : NaN
end

return K

mtl_layer = geotiff.("./assets/mtl.tif")

using Images
(mtl_layer)

### SHP
# open a vector file
ds_point = GDAL.openex("./assets/mtl/mtl.shp", GDAL.GDAL_OF_VECTOR, C_NULL, C_NULL, C_NULL)

# create a rasterize options object
options = GDAL.rasterizeoptionsnew(["-of","MEM","-tr","0.05","0.05"], C_NULL)
# rasterize the vector, in this case to an in memory raster (https://www.gdal.org/frmt_mem.html)
ds_rasterize = GDAL.rasterize("data/point-rasterize.mem", Ptr{GDAL.GDALDatasetH}(C_NULL), ds_point, options, C_NULL)
# tell GDAL to free the rasterize options object
GDAL.rasterizeoptionsfree(options)

# close the datasets
GDAL.close(ds_rasterize)
GDAL.close(ds_point)

mtl_layer
for i in 1:length(mtl_layer)
    if isnan(mtl_layer[i])
        mtl_layer[i] = 0
    else
        mtl_layer[i] = 1
    end
end
mtl_layer
heatmap(mtl_layer)

## ArchGDAL alternative
using ArchGDAL; const AG = ArchGDAL
# Open raster
AG.registerdrivers() do
    AG.read("./assets/mtl.tif") do dataset
    band1 = AG.getband(dataset,1)
    new1 = AG.read(band1)
    end
end

# Get useful properties
ref = AG.getproj(dataset)
geotransform = AG.getgeotransform(dataset)
# Width & height
width = ArchGDAL.width(dataset)
height = ArchGDAL.height(dataset)
# Number of raster bands
number_rasters = (ArchGDAL.nraster(dataset)
