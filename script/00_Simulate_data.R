#### Preamble ####
# Purpose: Simulates dataset about life expectancy and related factors 
# Author: Yufei Liu
# Date: 22 Oct 2023
# Contact: florence.liu@mail.utoronto.ca
# License: MIT

#### Data expectations ####
# The difference in days between the occurrence date and report date is positive and cencered at 0
# Expect more lost outside locations and different location types
# Expect much more stolen status than recovery status
# Have columns: occurrence_year, occurrence_month, difference, location, status

#### Workspace setup ####
library(tidyverse)


#### Simulate data ####
set.seed(777) # set a random seed for simulation
n <- 56 # sample size of simulation

### Simulate data for life expectancy, prevalence of tobacco, and alcohol consumption
life_expectancy <- round(runif(n, min = 0, max = 30), 1)
prevalence_of_tobacco <- round(runif(n, min = 0, max = 100), 1)
alcohol_consumption <- round(runif(n, min = 0, max = 30), 1)


### Simulate data for region, year, sex
region <- c(rep("Global", 8), rep("Africa", 8), rep("Americas", 8), 
            rep("South-East Asia", 8), rep("Europe", 8),
            rep("Eastern Mediterranean", 8), rep("Western Pacific", 8))

year <- rep(c("2019", "2015", "2010", "2000"), 14)
  
sex <- rep(c(rep("male", 4), rep("female", 4)), 7)

### Simulated dataset 
simulated_data <- data.frame(region, year, sex, life_expectancy, 
                             prevalence_of_tobacco, alcohol_consumption)


#### Test simulated data ####

### Check the unique values in region, year, and sex
simulated_data$region |> unique()
simulated_data$year |> unique()
simulated_data$sex |> unique()

### Check variable types
simulated_data$region |> class() == "character"
simulated_data$year |> class() == "character"
simulated_data$sex |> class() == "character"
simulated_data$life_expectancy|> class() == "numeric"
simulated_data$alcohol_consumption |> class() == "numeric"
simulated_data$prevalence_of_tobacco |> class() == "numeric"

### Check that the life expectancy, prevalence of tobacco, and alcohol consumption is non-negative
simulated_data$life_expectancy |> min() >= 0
simulated_data$prevalence_of_tobacco |> min() >= 0
simulated_data$alcohol_consumption |> min() >= 0


#### Save simulated data ####
write_csv(merged_data, "outputs/data/simulated_data.csv")
