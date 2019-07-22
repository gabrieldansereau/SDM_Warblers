## Testing ECDF function

using StatsBase
using Statistics
using DataFrames
using CSV
using Random

#### Basic try

## 1. Train resolution > test resolution
# Get train values
train1 = collect(1:100)
shuffle!(train1)

# Create ECDF function
qfinder1 = ecdf(train1)
qfinder1.(train1)

# Get test values
test1 = collect(1:10)*10
shuffle!(test1)

# Test ECDF function
qfinder1.(test1)

## 2. Train resolution < test resolution
# Get train values
train2 = collect(1:10)*10
shuffle!(train2)

# Create ECDF function
qfinder2 = ecdf(train2)
qfinder2.(train2)

# Get test values
test2 = collect(1:100)
shuffle!(test2)

# Test ECDF function
qfinder2.(test2)

########

#### Try with random values
# Generate random values
possible_values = collect(1:100)

# 3. Train resolution > test resolution
train3 = rand(possible_values, 100)
test3 = rand(possible_values, 10)

qfinder3 = ecdf(train3)
qfinder3.(train3)
test3
qfinder3.(test3)

# 4. Train resolution < test resolution
train4 = rand(possible_values, 10)
test4 = rand(possible_values, 100)

qfinder4 = ecdf(train4)
qfinder4.(train4)
test4
qfinder4.(test4)

########

#### Try with values from random distribution
using Distributions

# Create random distribution
rnorm = Normal(50,30)
# Fine scale sample
fine = round.(rand(rnorm, 100))
# Coarse scale sample
coarse = round.(rand(rnorm, 10))

# Use fine scale as model
qfinder_fine = ecdf(fine)
fine
qfinder_fine(fine)
coarse
qfinder_fine(coarse)

# Use coase scale as model
qfinder_coarse = ecdf(coarse)
coarse
qfinder_coarse(coarse)
fine
qfinder_coarse(fine)
