library(ggplot2)

# Create distributions
dist1 <- rnorm(100, 42, 3)
dist2 <- rnorm(100, 42, 3)
dist3 <- rnorm(100, 42, 3)

# Create histograms
hist1 <- qplot(dist1)
hist2 <- qplot(dist2)
hist3 <- qplot(dist3)

# View histograms
hist1
hist2
hist3


#######

# Usign assign() for variable names
sp_names <- c("sp1", "sp2", "sp3")

for(i in 1:3){
  assign(sp_names[i], rnorm(100, 42, 3))
  assign(paste("hist_",sp_names[i],sep=""), hist(get(sp_names[i])))
}

plot(hist_sp1)
plot(hist_sp2)
plot(hist_sp3)
