#### Explore eBird Dataset ####

library(auk)
library(lubridate)
library(sf)
library(gridExtra)
library(tidyverse)

# resolve namespace conflicts
select <- dplyr::select

# Set ebd path
# auk::auk_set_ebd_path("~/github/data/ebd/")
# Restart session

## Explore EBD Sample ####

# Load data
ebd_sample <- read.csv("../data/ebd/ebd_sample.txt", header=T, sep="\t")

# # Fix names format
# names(ebd_sample) = gsub("\\.", "_", names(ebd_sample))
# names(ebd_sample)

# Check data
head(ebd_sample)
table(ebd_sample$PROTOCOL.TYPE)
table(ebd_sample$SCIENTIFIC.NAME)

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

## Test Data Extraction with EBD Sample ####

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
f_ebd <- "../data/ebd/ebd_test.csv"
auk_filter(ebd_filters, file = f_ebd, overwrite = T)

# Test exported file
test <- read.csv("../data/ebd/ebd_test.csv", header = T, sep = "\t")
head(test)
table(test$SCIENTIFIC.NAME)
table(test$PROTOCOL.TYPE)

## Extract data from complete database ####

# Check worldwide distribution for a few species (manually from eBird website)
amN <- c("Myioborus miniatus", "Myioborus pictus",
         "Cardellina rubrifrons")
amS <- c("Myioborus albifrons", "Myioborus melanocephalus", 
         "Myioborus ornatus", "Myioborus flavivertex",
         "Myioborus pariae", "Myioborus castaneocapilla",
         "Myioborus brunniceps", "Myiothlypis rivularis",
         "Myiothlypis nigrocristata", "Myiothlypis leucoblephara",
         "Myiothlypis luteoviridis")
amC <- c("Myioborus torquatus", "Cardellina versicolor", 
         "Cardellina rubra")
nul <- c("Myioborus albifacies", "Myioborus cardonai")
# Remove a few species not present in North America
to_remove <- c(amS, nul)
fewer_parulidae_species <- parulidae_species[!(parulidae_species %in% to_remove)]
fewer_parulidae_species

# Get ebd file
ebd <- auk_ebd("ebd_relJun-2019.txt",
               file_sampling = "ebd_sampling_relJun-2019.txt")
ebd_sampling <- auk_samp
# Apply filters
ebd_filters <- ebd %>% 
  auk_species(fewer_parulidae_species) %>% 
  auk_country(c("CA", "US", "MX")) %>% 
  auk_complete()
ebd_filters
ebd_sampling_filters <- ebd_sampling %>% 
  auk_country(c("CA", "US", "MX")) %>% 
  auk_complete()
ebd_sampling_filters
# Export filtered data !!! SEVERAL HOURS !!!!
f_ebd <- "../data/ebd/ebd_warblers.csv"
f_sampling <- "../data/ebd/ebd_warblers_sampling.csv"
auk_filter(ebd_filters, file = f_ebd, file_sampling = f_sampling)
auk_filter(ebd_sampling_filters, file = f_sampling)
# File is too big, need to cut in terminal

# Select variables to keep
vars <- c("CATEGORY", "SCIENTIFIC.NAME", "SUBSPECIES.SCIENTIFIC.NAME", "OBSERVATION.COUNT", "COUNTRY.CODE", 
          "LATITUDE", "LONGITUDE", "OBSERVATION.DATE", "PROTOCOL.TYPE", "DURATION.MINUTES",
          "EFFORT.DISTANCE.KM", "NUMBER.OBSERVERS", "ALL.SPECIES.REPORTED", "APPROVED") 
# Get column indices
inds <- which(names(ebd_sample) %in% vars)
inds

# Bash command
# cut -f4,6,8,9,14,26,27,28,32,35,36,38,39,42 ebd_warblers.csv > ebd_warblers_cut.csv

## Test exported file ####
warblers <- read.csv("../data/ebd/ebd_warblers_cut.csv", header = T, sep = "\t")
head(warblers)
warblers_sampling <- read.csv("../data/ebd/ebd_warblers_sampling.csv", header = T, sep = "\t")
head(warblers_sampling)

# Check summary
warblers_summary <- summary(warblers) # takes some time
warblers_summary

# Check categories
warblers %>% 
  filter(CATEGORY == "form") %>%
  select(CATEGORY, SCIENTIFIC.NAME, SUBSPECIES.SCIENTIFIC.NAME) %>% 
  head(50)
warblers %>% 
  filter(CATEGORY == "intergrade") %>%
  select(CATEGORY, SCIENTIFIC.NAME, SUBSPECIES.SCIENTIFIC.NAME) %>% 
  head(50)
warblers %>% 
  filter(CATEGORY == "issf") %>%
  select(CATEGORY, SCIENTIFIC.NAME, SUBSPECIES.SCIENTIFIC.NAME) %>% 
  head(50)

# Check species
unique(warblers$SCIENTIFIC.NAME) # 63
# Check subspecies
unique(warblers$SUBSPECIES.SCIENTIFIC.NAME) # 41
# Check counts
sort(unique(warblers$OBSERVATION.COUNT)) # X is weird
warblers %>% 
  filter(OBSERVATION.COUNT != "X") %>%
  pull(OBSERVATION.COUNT) %>% 
  as.numeric %>% 
  hist

# Check longitude
filter(warblers, LONGITUDE > 0) # possibly and error

warblers_strict <- warblers %>%
  filter(CATEGORY == "species", 
         OBSERVATION.COUNT != "X",
         LONGITUDE < 0,
         PROTOCOL.TYPE == "Traveling",
         APPROVED == 1) %>% 
  droplevels
summary(warblers_strict)

# Transform dates
tmp <- head(warblers, 10)
tmp %>% 
  mutate_at(vars(OBSERVATION.DATE), list(YEAR = year, MONTH = month, DAY = day))
warblers <- warblers %>% 
  mutate_at(vars(OBSERVATION.DATE), list(YEAR = year, MONTH = month, DAY = day))

# Check dates
warblers %>% 
  count(YEAR) %>% 
  print.data.frame()
warblers %>% 
  count(MONTH) %>% 
  print.data.frame()
warblers %>% 
  count(DAY) %>% 
  print.data.frame()

## Zero-filling ####
f_ebd <- "../data/ebd/ebd_warblers.csv"
f_sampling <- "../data/ebd/ebd_warblers_sampling.csv"
ebd_zf <- auk_zerofill(f_ebd, f_sampling, collapse = TRUE)
