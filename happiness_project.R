# Importing packages 

library(tidyverse)
library(ggplot2)
library(spData)
library(sf)
library(fastDummies)
library(corrplot)
library(rpart)
library(rattle)
library(caret)
library(leaps)
library(sjPlot)

# Importing the data

data_2015 <- read_csv("Data/2015.csv")
data_2016 <- read_csv("Data/2016.csv")
data_2017 <- read_csv("Data/2017.csv")
data_2018 <- read_csv("Data/2018.csv")
data_2019 <- read_csv("Data/2019.csv")

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

#Checking which countries and regions have the highest happiness scores
#Getting rid of duplicates (only using highest score for each country)

happiest <- full_df[order(-full_df$happy_score),] #Sorting score from high to low
happiest <- happiest %>% distinct(country, .keep_all = TRUE) #Removing duplicates
top_20_countries <- head(happiest$country, 20) #Taking top 20 countries
top_20_region <- head(happiest$region, 20) #Including region
top_20_scores <- head(happiest$happy_score, 20) #Taking top 20 scores
top_20 <- cbind.data.frame(top_20_countries,top_20_region,top_20_scores)

#Creating a bar plot to display the happiness scores of the 20 happiest countries

top_20_plot <- ggplot(top_20, aes(x=reorder(top_20_countries,top_20_scores), y=top_20_scores, fill=top_20_region)) +
  geom_bar(stat = "identity",color="black")+
  geom_text(aes(label=round(top_20_scores,2)),vjust=0.5,hjust=1.2,color="black",  position = position_dodge(0.9),
            size=3.5) +
  labs(title="20 Happiest Countries",x = "Country",y = "Happiness Score") +
  scale_fill_brewer(name = "Region of the World",palette = "Pastel2") +
  theme_minimal() + coord_flip()
print(top_20_plot)


#Checking which countries and regions have the lowest happiness scores
#Getting rid of duplicates (only using lowest score for each country)

least_happy <- full_df[order(full_df$happy_score),] #Sorting score in ascending order
least_happy <- least_happy %>% distinct(country, .keep_all = TRUE) #Removing duplicates
bot_20_countries <- head(least_happy$country, 20) #Taking bottom 20 countries
bot_20_region <- head(least_happy$region, 20) #Including region
bot_20_scores <- head(least_happy$happy_score, 20) #Taking bottom 20 scores
bot_20 <- cbind.data.frame(bot_20_countries,bot_20_region,bot_20_scores)

bot_20_plot <- ggplot(bot_20, aes(x=reorder(bot_20_countries,-bot_20_scores), y=bot_20_scores, fill=bot_20_region)) +
  geom_bar(stat = "identity",color="black")+
  geom_text(aes(label=round(bot_20_scores,2)),vjust=0.5,hjust=1.2,color="black",  position = position_dodge(0.9),
            size=3.5) +
  labs(title="20 Least Happy Countries",x = "Country",y = "Happiness Score") +
  scale_fill_brewer(name = "Region of the World",palette = "Pastel1") +
  theme_minimal() + coord_flip()
print(bot_20_plot)


#Looking at happiness score over time



m2015 <- mean(data_2015$happy_score)
m2016 <- mean(data_2016$happy_score)
m2017 <- mean(data_2017$happy_score)
m2018 <- mean(data_2018$happy_score)
m2019 <- mean(data_2019$happy_score)

yr <- c(2015,2016,2017,2018,2019)
m <- c(m2015,m2016,m2017,m2018,m2019)
time_df <- data.frame(yr,m)

#Plotting the mean happiness score from 2015 to 2019

happy_line <- ggplot(data=time_df, aes(x=yr, y=m, group=1)) +
  geom_line(color="aquamarine4",lwd=1)+
  geom_point(color="lightcyan3",lwd=3) + theme_minimal() + labs(title="Mean Happiness Score Over Time",
                                                    x="Year",y="Mean Happiness Score") +
  theme(plot.title = element_text(hjust = 0.5))

print(happy_line)



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

happy_map <- function(var,title,color,name)
{
  map <- ggplot() +
    geom_sf(data=merged_df, aes(fill=var,geometry=geometry)) +
    scale_fill_distiller(palette=color) +
    ggtitle(title) + theme(plot.title = element_text(hjust = 0.5)) + labs(fill=name)
  print(map)
  
}

#Creating a map displaying happiness score across the world

happy_map(merged_df$happy_score,"Happiness Score Around the World","BuGn","Happiness Score")

#Creating a map displaying life expectancy across the world

happy_map(merged_df$life_expectancy, "Healthy Life Expectancy","YlGnBu","Life Expectancy Score")

#Creating a map displaying gdp across the world

happy_map(merged_df$gdp, "GDP", "PuBuGn","Logged GDP")

#Creating a map displaying social support across the world

happy_map(merged_df$social_support, "Social Support / Family", "BuPu", "Social Support Score")

#Creating a map displaying freedom across the world

happy_map(merged_df$freedom, "Freedom to Make Life Choices", "PuRd", "Freedom Score")

#Creating a map displaying trust in government 

happy_map(merged_df$trust, "Trust in Government", "Greens", "Trust Score")

#Creating a map displaying generosity

happy_map(merged_df$generosity, "Generosity", "Purples", "Generosity Score")


#Creating a violin plot of happiness score to further examine how happiness score
#differs by region

violin_plot <- ggplot(full_df,aes(x=region,y=happy_score))+
  geom_violin(aes(fill=factor(region)),alpha=0.4,width=5)+
  theme(plot.title = element_text(hjust = 0.5),axis.text.x = element_text(angle=90, vjust=0.8)) + 
  labs(title="Happiness Score by Region",x="Region",y="Happiness Score",fill="Region") + 
  scale_fill_brewer(palette="PiYG") + 
  stat_summary(fun = "mean",geom = "point", width = 0.5,color = "blue4") 
print(violin_plot)


#Evaluating the relationship between happiness score and various independent variables

#Creating scatterplots of happiness score vs. different factors

#Creating a function that creates a scatterplot with happiness score on the y axis
#and whatever variable (gdp, social support, freedom, etc) is inputted into 
#the function on the x-axis

happy_plot <- function(var, title, xlab, ylab)
{
  plot <- ggplot(full_df, aes(x=var, y=happy_score, color=region)) +
    geom_point() + labs(title=title, x=xlab, y=ylab) + 
    scale_fill_brewer(palette="Spectral") + theme_minimal() + 
    guides(col=guide_legend("Region of the World")) + 
    theme(plot.title = element_text(hjust = 0.5))
  print(plot)
}

#Creating a plot for happiness score vs life expectancy

happy_plot(full_df$life_expectancy, "Happiness Score vs. Life Expectancy", "Life Expectancy Score", "Happiness Score")

#Creating a plot for happiness score vs GDP

happy_plot(full_df$gdp, "Happiness Score vs. GDP", "Logged GDP", "Happiness Score")

#Creating a plot for happiness score vs social support

happy_plot(full_df$social_support, "Happiness Score vs. Social Support", "Social Support Score", "Happiness Score")

#Creating a plot for happiness score vs freedom

happy_plot(full_df$freedom, "Happiness Score vs. Freedom", "Freedom Score", "Happiness Score")

#Creating a plot for happiness score vs trust in government

happy_plot(full_df$trust, "Happiness Score vs. Trust in Goverment", "Trust Score", "Happiness Score")

#Creating a plot for happiness score vs generosity

happy_plot(full_df$generosity,"Happiness Score vs. Generosity", "Generosity Score", "Happiness Score")



#Determining the correlation between happiness score and various independent variables

#Creating subset of the dataframe with only happiness score and independent variables

df_subset <- subset(full_df, select = c(happy_score,gdp,life_expectancy, social_support, freedom, trust, generosity))

#Constructing correlation matrix

cor_mat <- round(cor(df_subset),2) 
colnames(cor_mat) <- c("Happiness Score", "GDP", "Life Expectancy", "Social Support",
                       "Freedom", "Trust", "Generosity")
rownames(cor_mat) <- c("Happiness Score", "GDP", "Life Expectancy", "Social Support",
                       "Freedom", "Trust", "Generosity")

#Plotting the correlation matrix

cor_plot <- corrplot(cor_mat, method = 'circle', title= "Correlation Between Different Factors", 
                     mar=c(1,1,2,1), order = "AOE",
                     col.lim = c(-0.03,1),tl.col="black", 
                     tl.pos="lt", col=COL1("Greens"),
                     cl.pos='b',cl.ratio=0.1, addgrid.col="white",addCoef.col = 'black')
print(cor_plot)


#Potential problem: gdp, life expectancy, and social support are very strongly
#correlated amongst each other -- all characteristics of developed countries

#Scaling the data for linear regression

df_scale <- as.data.frame(scale(full_df[,5:11],center=TRUE,scale=TRUE))
df_scale['region'] <- full_df['region'] #Adding region back into the dataframe


#Stepwise regression model using k-fold cross validation

set.seed(123)
train.control <- trainControl(method = "cv", number = 10)
step_model <- train(happy_score ~ gdp + social_support + life_expectancy + 
                      freedom + trust + generosity, data = df_scale,
                    method = "leapSeq", 
                    tuneGrid = data.frame(nvmax = 1:6),
                    trControl = train.control
)

summary(step_model$finalModel) #Displaying the results of the model
step_model$bestTune #Checking which model is the best out of the 6

#Showing the coefficients of the final model

#Final model > happiness score = gdp + social support +
#life expectancy + freedom + trust in government + generosity (+error term)


happy_reg <- lm(happy_score ~ gdp + social_support + life_expectancy + freedom + trust + generosity,
             data = df_scale)
summary(happy_reg)

#Creating a table to show results

my_table <- tab_model(happy_reg, digits = 3, show.ci = F, show.stat = T, 
                              show.se = T, p.style = "stars",
                              pred.labels = c("(Intercept)", "GDP","Social Support",
                                              "Healthy Life Expectancy","Freedom",
                                              "Trust in Government","Generosity"),
                      title = "Final Model", dv.labels = c(""))
print(my_table)

#Adding region dummy variables into the model to control for region

#Creating dummy variables for region

full_df_dummies <- dummy_cols(df_scale, select_columns = 'region')

#Additional linear regression model > happiness score = gdp + social support + 
#life expectancy + freedom + trust in government + generosity + region (+error term)

happy_reg_2 <- lm(happy_score ~ gdp + social_support + life_expectancy + freedom +
                    trust + generosity + region, data = full_df_dummies)
summary(happy_reg_2)

#Using one final approach: a regression tree

#Regression tree model

happy_tree <- rpart(happy_score ~ gdp + social_support + life_expectancy + freedom + trust + generosity, data = df_scale)
happy_tree_plot <- fancyRpartPlot(happy_tree, main = "Happiness Score", sub = "", palettes = "PuBuGn")
print(happy_tree_plot)



