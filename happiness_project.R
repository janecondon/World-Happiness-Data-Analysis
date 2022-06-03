# Importing packages 

library(tidyverse)
library(ggplot2)
library(spData)
library(sf)
library(rworldmap)

# Importing the data

data_2015 <- read_csv("2015.csv")
data_2016 <- read_csv("2016.csv")
data_2017 <- read_csv("2017.csv")
data_2018 <- read_csv("2018.csv")
data_2019 <- read_csv("2019.csv")

#Cleaning up the data

#Renaming columns, adding "year" column, and adding region where missing

data_2015 <- data_2015 %>%
  rename(country = "Country", region = "Region", happy_rank = "Happiness Rank", happy_score = 
           "Happiness Score",
         gdp = "Economy (GDP per Capita)", social_support = "Family", life_expectancy = "Health (Life Expectancy)",
         freedom = "Freedom", trust = "Trust (Government Corruption)", generosity = "Generosity",
         dystopia_res = "Dystopia Residual")
data_2015$year <- 2015


data_2016 <- data_2016 %>%
  rename(country = "Country", region = "Region", happy_rank = "Happiness Rank", 
         happy_score = "Happiness Score", gdp = "Economy (GDP per Capita)", social_support = 
           "Family", life_expectancy = "Health (Life Expectancy)", freedom = "Freedom", 
         trust = "Trust (Government Corruption)", generosity = "Generosity", 
         dystopia_res = "Dystopia Residual")
data_2016$year <- 2016

data_2017 <- data_2017 %>% 
  rename(country = "Country", happy_rank = "Happiness.Rank", happy_score = "Happiness.Score",
         gdp = "Economy..GDP.per.Capita.", social_support = "Family", life_expectancy = 
           "Health..Life.Expectancy.", freedom = "Freedom", trust = "Trust..Government.Corruption.",
         generosity = "Generosity", dystopia_res = "Dystopia.Residual")
data_2017$year <- 2017
data_2017$region <- data_2016$region[match(data_2017$country,data_2016$country)]

data_2018 <- data_2018 %>%
  rename(happy_rank = "Overall rank", country = "Country or region", happy_score = 
           "Score", gdp = "GDP per capita", social_support = "Social support",
         life_expectancy = "Healthy life expectancy", freedom = "Freedom to make life choices",
         generosity = "Generosity", trust = "Perceptions of corruption")
data_2018$year <- 2018
data_2018$region <- data_2016$region[match(data_2018$country,data_2016$country)]

data_2019 <- data_2019 %>%
  rename(happy_rank = "Overall rank", country = "Country or region", happy_score = 
           "Score", gdp = "GDP per capita", social_support = "Social support",
         life_expectancy = "Healthy life expectancy", freedom = "Freedom to make life choices",
         generosity = "Generosity", trust = "Perceptions of corruption")
data_2019$year <- 2019
data_2019$region <- data_2016$region[match(data_2019$country,data_2016$country)]

#Checking datatypes

sapply(c(data_2015,data_2016,data_2017,data_2018,data_2019), class) 

#Changing "trust" variable (from 2018 dataset) from character to numeric

data_2018 <- data_2018[!is.na(as.numeric(data_2018$trust)), ]
data_2018$trust <- as.numeric(data_2018$trust)

#Combining dataframes (2015, 2016, 2017, 2018, 2019)

full_df <- bind_rows(data_2015,data_2016,data_2017,data_2018,data_2019)

#Removing unnecessary columns

full_df <- subset(full_df, select = c(country, region, year, happy_rank, happy_score, gdp,
                                      social_support, life_expectancy, freedom, trust,
                                      generosity))
#Removing NA values

full_df <- na.omit(full_df)


#Exploratory data analysis

#Creating scatterplots of happiness score vs. different factors

#Creating a function that creates a scatterplot with happiness score on the y axis
#and whatever variable (gdp, social support, freedom, etc) is inputted into 
#the function on the x-axis

happy_plot <- function(var, title, xlab, ylab)
{
  plot <- ggplot(full_df, aes(x=var, y=happy_score, color=region)) +
    geom_point() + labs(title=title, x=xlab, y=ylab) + 
    scale_color_brewer(palette="Spectral") + theme_minimal() + 
    guides(col=guide_legend("Region of the World"))
  print(plot)
}

#Creating a plot for happiness score vs life expectancy

happy_plot(full_df$life_expectancy, "Happiness Score vs. Life Expectancy", "Life Expectancy Score", "Happiness Score")

#Creating a plot for happiness score vs GDP

happy_plot(full_df$gdp, "Happiness Score vs. GDP", "GDP Score", "Happiness Score")

#Creating a plot for happiness score vs social support

happy_plot(full_df$social_support, "Happiness Score vs. Social Support", "Social Support Score", "Happiness Score")

#Creating a plot for happiness score vs freedom

happy_plot(full_df$freedom, "Happiness Score vs. Freedom", "Freedom Score", "Happiness Score")

#Creating a plot for happiness score vs trust in government

happy_plot(full_df$trust, "Happiness Score vs. Trust in Goverment", "Trust Score", "Happiness Score")

#Creating a plot for happiness score vs generosity

happy_plot(full_df$generosity,"Happiness Score vs. Generosity", "Generosity Score", "Happiness Score")



#Visualizing the data on a map

#Obtaining spatial data/world map

data("world", package="spData")
world_map <- world

#Changing world map country names to match the original dataset

world_map$name_long <- gsub("Russian Federation", "Russia", world_map$name_long)
world_map$name_long <- gsub("Republic of Korea", "South Korea", world_map$name_long)
world_map$name_long <- gsub("Dem. Rep. Korea", "North Korea", world_map$name_long)
world_map$name_long <- gsub("Democratic Republic of the Congo", "Congo (Kinshasa)", world_map$name_long)
world_map$name_long <- gsub("Republic of the Congo", "Congo (Brazzaville)", world_map$name_long)
world_map$name_long <- gsub("Lao PDR", "Laos", world_map$name_long)
world_map$name_long <- gsub("Côte d'Ivoire", "Ivory Coast", world_map$name_long)


#Merging the full happiness dataset with the "world map" spatial dataset,
#selecting data from the most recent year for each country in order to construct heatmaps

merged_df <- merge(world_map,full_df,by.x="name_long",by.y = "country",all.x=TRUE)
merged_df <- merged_df[order(-merged_df$year),]
merged_df <- merged_df %>% distinct(geometry,.keep_all=TRUE)

#Creating a function that creates a map for different variables for the most recent year
#that data is present for each country

happy_map <- function(var,title,color)
{
  map <- ggplot() +
    geom_sf(data=merged_df, aes(fill=var,geometry=geometry)) +
    scale_fill_distiller(palette=color) +
    ggtitle(title)
  print(map)
  
}

#Creating a map displaying happiness score across the world

happy_map(merged_df$happy_score,"Happiness Score","YlOrRd")

#Creating a map displaying life expectancy across the world

happy_map(merged_df$life_expectancy, "Life Expectancy","YlGnBu")

#Creating a map displaying gdp across the world

happy_map(merged_df$gdp, "GDP", "PuBuGn")

#Creating a map displaying social support across the world

happy_map(merged_df$social_support, "Social Support", "BuPu")

#Creating a map displaying freedom across the world

happy_map(merged_df$freedom, "Freedom", "PuRd")

#Creating a map displaying trust in government 

happy_map(merged_df$trust, "Trust in Government", "Spectral")

#Creating a map displaying generosity

happy_map(merged_df$generosity, "Generosity", "RdPu")



#Determining the relationship between happiness score and various independent variables
#using various methods

#Ordinary linear regression model > happiness score = gdp + social support +
#life expectancy + freedom + trust in government + generosity (+error term)


happy_reg <- lm(happy_score ~ gdp + social_support + life_expectancy + freedom + trust + generosity,
            data = full_df)
summary(happy_reg)
