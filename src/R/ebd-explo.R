#### Explore eBird Dataset

library(auk)
library(lubridate)
library(sf)
library(gridExtra)
library(tidyverse)

# resolve namespace conflicts
select <- dplyr::select

## Explore EBD Sample

# Load data
ebd_sample <- read.csv("../data/ebd/ebd_sample/ebd_sample.txt", header=T, sep="\t")

# Fix names format
names(ebd_sample) = gsub("\\.", "_", names(ebd_sample))
names(ebd_sample)

# Check data
head(ebd_sample)
table(ebd_sample$PROTOCOL_TYPE)
table(ebd_sample$SCIENTIFIC_NAME)

# Check taxonomy
names(ebird_taxonomy)
head(ebird_taxonomy)

# Extract Parulidae taxonomy information
parulidae_taxonomy <- filter(ebird_taxonomy, family == "Parulidae")
head(parulidae_taxonomy)
View(parulidae_taxonomy)
# Extract Parulidae species names (species only, no hybrid-issf-spuh-...)
parulidae_species <- parulidae_taxonomy %>%
  filter(category == "species") %>% 
  pull(scientific_name)
parulidae_species

## Test Data Extraction with EBD Sample

# Set path
# auk::auk_set_ebd_path("~/github/data/ebd/ebd_sample/")
# Restart session

# Get ebd file
ebd <- auk_ebd("ebd_sample.txt")
# Apply filters
ebd_filters <- ebd %>% 
  auk_species(parulidae_species[1:97]) %>% 
  auk_country(c("CA", "US", "MX")) %>% 
  auk_complete()
ebd_filters
# Not working for more than 97 species at the time...
# Generates "Error running AWK command"
# [1:97], [98:110], [14:110] all work

# Export filtered data
f_ebd <- "../data/ebd/ebd_test.txt"
auk_filter(ebd_filters, file = f_ebd, overwrite = T)
# Test exported file
test <- read.csv("../data/ebd/ebd_test.txt", header = T, sep = "\t")
head(test)
table(test$SCIENTIFIC.NAME)
table(test$PROTOCOL.TYPE)
