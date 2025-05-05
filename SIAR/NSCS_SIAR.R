library(siar);
library(openxlsx);

## ZJ
# Read data
setwd("./ZJ"); # Specify the folder where data is stored
data <- read.xlsx('ConsumerData.xlsx',sheet=1);
sources <- read.xlsx('SourceData.xlsx',sheet=1);
#tef <- read.xlsx('TEFData.xlsx',sheet=1);
# Output model results
concs <- 0
# Output model results
model1 <- siarmcmcdirichletv4(data,sources,corrections=0,concs)
# Plotting
X11()
siarplotdata(model1) # Plot original data and endmembers
X11()
siarproportionbygroupplot(model1,grp=1) # Plot contribution graph of each source for a specific mixture (group)
# Display contribution values
siarhdrs(model1)


## NBBG
# Read data
setwd("./NBBG"); # Specify the folder where data is stored
data <- read.xlsx('ConsumerData.xlsx',sheet=1);
sources <- read.xlsx('SourceData.xlsx',sheet=1);
#tef <- read.xlsx('TEFData.xlsx',sheet=1);
# Output model results
concs <- 0
# Output model results
model1 <- siarmcmcdirichletv4(data,sources,corrections=0,concs)
# Plotting
X11()
siarplotdata(model1) # Plot original data and endmembers
X11()
siarproportionbygroupplot(model1,grp=1) # Plot contribution graph of each source for a specific mixture (group)
# Display contribution values
siarhdrs(model1)


# SBBG
# Read data
setwd("./SBBG"); # Specify the folder where data is stored
data <- read.xlsx('ConsumerData.xlsx',sheet=1);
sources <- read.xlsx('SourceData.xlsx',sheet=1);
#tef <- read.xlsx('TEFData.xlsx',sheet=1);
# Output model results
concs <- 0
# Output model results
model1 <- siarmcmcdirichletv4(data,sources,corrections=0,concs)
# Plotting
X11()
siarplotdata(model1) # Plot original data and endmembers
X11()
siarproportionbygroupplot(model1,grp=1) # Plot contribution graph of each source for a specific mixture (group)
# Display contribution values
siarhdrs(model1)


# QD
# Read data
setwd("./QD"); # Specify the folder where data is stored
data <- read.xlsx('ConsumerData.xlsx',sheet=1);
sources <- read.xlsx('SourceData.xlsx',sheet=1);
#tef <- read.xlsx('TEFData.xlsx',sheet=1);
# Output model results
concs <- 0
# Output model results
model1 <- siarmcmcdirichletv4(data,sources,corrections=0,concs)
# Plotting
X11()
siarplotdata(model1) # Plot original data and endmembers
X11()
siarproportionbygroupplot(model1,grp=1) # Plot contribution graph of each source for a specific mixture (group)
# Display contribution values
siarhdrs(model1)


# YX
# Read data
setwd("./YX"); # Specify the folder where data is stored
data <- read.xlsx('ConsumerData.xlsx',sheet=1);
sources <- read.xlsx('SourceData.xlsx',sheet=1);
#tef <- read.xlsx('TEFData.xlsx',sheet=1);
# Output model results
concs <- 0
# Output model results
model1 <- siarmcmcdirichletv4(data,sources,corrections=0,concs)
# Plotting
X11()
siarplotdata(model1) # Plot original data and endmembers
X11()
siarproportionbygroupplot(model1,grp=1) # Plot contribution graph of each source for a specific mixture (group)
# Display contribution values
siarhdrs(model1)


# LZ
# Read data
setwd("./LZ"); # Specify the folder where data is stored
data <- read.xlsx('ConsumerData.xlsx',sheet=1);
sources <- read.xlsx('SourceData.xlsx',sheet=1);
#tef <- read.xlsx('TEFData.xlsx',sheet=1);
# Output model results
concs <- 0
# Output model results
model1 <- siarmcmcdirichletv4(data,sources,corrections=0,concs)
# Plotting
X11()
siarplotdata(model1) # Plot original data and endmembers
X11()
siarproportionbygroupplot(model1,grp=1) # Plot contribution graph of each source for a specific mixture (group)
# Display contribution values
siarhdrs(model1)
