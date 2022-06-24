# World Happiness Report Data Analysis


## Introduction

This project involves an analysis of data from the World Happiness Report from 2015 to 2019. The purpose of this project is to answer an important question: which 
countries are the happiest, and what makes them so happy? On the other hand, which countries are the least happy and what makes them unhappy? Multiple techniques,
such as an exploratory data analysis, multivariate linear regression, stepwise regression, and regression trees will be utilized to predict happiness score and 
answer the question above. 
 

## The Data

All of the data used in this project comes directly from Kaggle.com. There are five datasets used in this project (World Happiness Report for 2015, 2016,
2017, 2018, and 2019), which were merged together into one large dataset for easier analysis. 

#### Response Variable (what we're trying to predict)

The reponse variable in this project is a country's happiness score. The data for happiness score comes from Gallup World Poll’s survey scores,
where Cantril’s Ladder of Life Scale was used to measure happiness. In order to obtain a happiness score, the survey asks respondents to imagine a ladder with
steps 0 to 10, with 0 being the absolute worst possible life, while 10 would be the best possible life. Respondents were then asked to rate their current lives based
on that scale. A country's happiness score is calculated by taking the national average of the survey responses. 


#### Explanatory Variables Explored

* Healthy Life Expectancy: 

* GDP

* Social Support

* Freedom to Make Life Choices

* Trust in Government

* Generosity


## Questions to be Answered

* **Which Countries are the Happiest and Which Are the Least Happy?** : out of all 153 countries in the dataset, which are the happiest, and which are the unhappiest?
In this project, the top 20 happiest countries as well as the bottom 20 countries will be determined. 


* **How does the Happiness Score of a Country Differ by Region?** : In addition to determining which countries are the happiest, the data will also be examined by
region to determine if there is a significant difference in the average happiness score among different regions. Which regions are the happiest and which are the 
unhappiest?

* **Which factors influence the level of happiness in a country?** : Do the explanatory variables above have any impact on a country's happiness score? If so,
what type of impact and how strong of an impact do they have? Which factors have the strongest impact on happiness score?

* **How have Happiness Scores Changed Over Time?** : As a whole, has the world gotten happier, or unhappier, in the period from 2015 to 2019?

