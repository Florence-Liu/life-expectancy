#### Preamble ####
# Purpose: Downloads the world health data about life expectancy from WHO Global Health Observatory data repository.
# Author: Yufei Liu
# Date: 22 Oct 2023
# Contact: florence.liu@mail.utoronto.ca
# License: MIT
# Download link: https://apps.who.int/gho/data/node.main.1?lang=en


#### Workspace setup ####
library(tidyverse)
library(janitor)



#### Download data ####
## Download three original datasets from WHO website: https://apps.who.int/gho/data/node.main.1?lang=en and save in input/data folder
## Import the datasets from input/data folder

data_life_expectancy <- read.csv("input/data/data_life_expectancy.csv")
data_tobacco <- read.csv("input/data/data_tobacco.csv")
data_alcohol <- read.csv("input/data/data_alcohol.csv")



#### Merge data ####

### Select columns for life expectancy at age 60 only
data_life_expectancy <- data_life_expectancy |> 
  janitor::clean_names()

data_life_expectancy <- data_life_expectancy |>
  select(x, x_1,
         life_expectancy_at_age_60_years_1, life_expectancy_at_age_60_years_2) |>
  rename(region = x, year = x_1, male = life_expectancy_at_age_60_years_1, 
         female = life_expectancy_at_age_60_years_2)

data_life_expectancy <- data_life_expectancy[-1,]


### Select columns for tobacco use prevalence data for 2019, 2015, 2010, 2000
data_tobacco <- data_tobacco |>
  janitor::clean_names()
  
data_tobacco <- data_tobacco |>
  rename(region = x,
         male.2019 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_4,
         female.2019 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_5,
         male.2015 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_10,
         female.2015 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_11,
         male.2010 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_13,
         female.2010 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_14,
         male.2000 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_19,
         female.2000 = estimate_of_current_tobacco_use_prevalence_age_standardized_rate_20)

data_tobacco <- data_tobacco[-c(1,2),] |> 
  select(region, male.2019, female.2019, male.2015, female.2015, 
         male.2010, female.2010, male.2000, female.2000)


### Remove range in values and select alcohol assumption for 2019, 2015, 2010, 2000
data_alcohol <- data_alcohol |>
  janitor::clean_names()

data_alcohol <- data_alcohol |>
  mutate(male.2019 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_1,"\\[.*"),
         female.2019 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_2,"\\[.*"),
         male.2015 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_4,"\\[.*"),
         female.2015 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_5,"\\[.*"),
         male.2010 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_7,"\\[.*"),
         female.2010 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_8,"\\[.*"),
         male.2000 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_13,"\\[.*"),
         female.2000 = str_remove(alcohol_total_per_capita_15_consumption_in_litres_of_pure_alcohol_sdg_indicator_3_5_2_14,"\\[.*")) |>
  select(x, male.2019, female.2019, male.2015, female.2015, male.2010, 
         female.2010, male.2000, female.2000)

data_alcohol <- data_alcohol[-c(1,2),] |>
  rename(region = x)


### Convert into datasets containing variables region, year, sex, life expectancy, alcohol, and tobacco
data_life_expectancy <- data_life_expectancy |>
  gather(sex, life_expectancy, male:female)

data_alcohol <- data_alcohol |>
  gather(sex_year, alcohol_consumption, male.2019:female.2000)

data_alcohol <- data_alcohol |>
  separate(sex_year, c("sex","year"), sep = "\\.")

data_tobacco <- data_tobacco |>
  gather(sex_year, prevalence_of_tobacco, male.2019:female.2000)

data_tobacco <- data_tobacco |>
  separate(sex_year, c("sex","year"), sep = "\\.")


### Merge into one dataset
merged_data <- data_life_expectancy |> full_join(data_alcohol) |>
  full_join(data_tobacco)

### Change variable types into numerical
merged_data$life_expectancy <- merged_data$life_expectancy |> as.numeric()
merged_data$prevalence_of_tobacco <- merged_data$prevalence_of_tobacco |> as.numeric()
merged_data$alcohol_consumption <- merged_data$alcohol_consumption |> as.numeric()



#### Test data ####

### Check the unique values in region, year, and sex
merged_data$region |> unique()
merged_data$year |> unique()
merged_data$sex |> unique()

### Check variable types
merged_data$region |> class() == "character"
merged_data$year |> class() == "character"
merged_data$sex |> class() == "character"
merged_data$life_expectancy|> class() == "numeric"
merged_data$alcohol_consumption |> class() == "numeric"
merged_data$prevalence_of_tobacco |> class() == "numeric"

### Check that the life expectancy, prevalence of tobacco, and alcohol consumption is non-negative
merged_data$life_expectancy |> min() >= 0
merged_data$prevalence_of_tobacco |> min() >= 0
merged_data$alcohol_consumption |> min() >= 0



#### Save data ####

### Save cleaned separate datasets
write_csv(data_life_expectancy, "outputs/data/cleaned_life_expectancy.csv")
write_csv(data_alcohol, "outputs/data/cleaned_alcohol.csv")
write_csv(data_tobacco, "outputs/data/cleaned_tobacco.csv")

### Save merged dataset
write_csv(merged_data, "outputs/data/merged_data.csv")
