#### Parulidae Data Extraction - Auk library ####
library(auk)

#### rgbif Tutorial ####
# https://ropensci.org/tutorials/rgbif_tutorial/
library(rgbif)

## Number of occurences
occ_count(basisOfRecord='OBSERVATION')
occ_count(taxonKey=2435099, georeferenced=TRUE)
occ_count(georeferenced=TRUE)
denmark_code <- isocodes[grep("Denmark", isocodes$name), "code"]
occ_count(country=denmark_code)
occ_count(datasetKey='9e7ea106-0bf8-4087-bb61-dfe4f29e0f17')
occ_count(datasetKey='e707e6da-e143-445d-b41d-529c4a777e8b', basisOfRecord='OBSERVATION')

## Search for taxon names
taxrank()
out <- name_lookup(query='parulidae')
names(out)
out$meta
head(out$data)
out$facets
out$hierarchies[1:2]
out$names[2]
# Search for genus
head(name_lookup(query='Setophaga', rank="genus", return="data")) # Paruline jaune

## Single occurence record
# Just data
occ_get(key=240713150, return='data')
# Just taxonomic hierarchy
occ_get(key=240713150, return='hier')
# All data, or leave return parameter blank
occ_get(key=240713150, return='all')
occ_get(key=240713150)
# Get many occurrences. occ_get is vectorized
occ_get(key=c(101010, 240713150, 855998194), return='data')

## Search for occurences
occ_search(scientificName = "Setophaga petechia", limit = 20) # Paruline jaune
# make sure name is right first
key <- name_suggest(q='Helianthus annuus', rank='species')$key[1]
occ_search(taxonKey=key, limit=20)
# choose parameter to return
occ_search(taxonKey=key, return='meta')
# choose fields to return
occ_search(scientificName = "Ursus americanus", fields=c('name','basisOfRecord','protocol'), limit = 20)
# vectorized parameters
splist <- c('Cyanocitta stelleri', 'Junco hyemalis', 'Aix sponsa')
keys <- sapply(splist, function(x) name_suggest(x)$key[1], USE.NAMES=FALSE)
occ_search(taxonKey=keys, limit=5)

## Maps
# map occurences
key <- name_backbone(name="Setophagia petechia")$speciesKey
dat <- occ_search(taxonKey = key, return='data', limit=500)
# library(ggplot2)
# gbifmap(dat)
x <- map_fetch(taxonKey = key, year = 2010)
library(raster)
plot(x, axes = FALSE, box = FALSE)

library(mapr)
# library(spocc)
# names(dat)[names(dat)=="decimalLatitude"] <- "latitude"
# names(dat)[names(dat)=="decimalLongitude"] <- "longitude"
map_plot(dat, lon="decimalLongitude", lat="decimalLatitude", size = 1, pch = 10)
