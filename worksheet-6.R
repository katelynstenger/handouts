## Web Scraping

library(httr)

response <- GET('http://research.jisao.washington.edu/pdo/PDO.latest')
response

library(rvest) 
library(xml2)
pdo_doc <- read_html(response)
pdo_doc

# from html, p contains info
pdo_node <- html_node(pdo_doc, "p")
pdo_text <- html_text(pdo_node)

library(stringr)
pdo_text_2017 <- str_match(pdo_text, "(?<=2017).*.(?=\\n2018)")

str_extract_all(pdo_text_2017[1], "[0-9-.]+")

## HTML Tables

census_vars_doc <- read_html('https://api.census.gov/data/2017/acs/acs5/variables.html')

table_raw <- html_node(census_vars_doc, 'table')

census_vars <- html_table(table_raw, fill = TRUE) 

library(tidyverse)

census_vars %>%
  set_tidy_names() %>%
  select(Name, Label) %>%
  filter(grepl('Median household income', Label))

## Web Services

path <- 'https://api.census.gov/data/2018/acs/acs5'
query_params <- list('get' = 'NAME,B19013_001E', 
                     'for' = 'county:*',
                     'in' = 'state:24')

response = GET(path, query = query_params)
response

response$headers['content-type']

## Response Content

library(jsonlite)

county_income <- response %>%
  content(as = 'text') %>%
  fromJSON() # converts to tabular format

# console
# head(county_income)


## Specialized Packages

library(tidycensus)
# can also use
# censusapi OR
# acs as alternatives

variables <- c('NAME', 'B19013_001E')

county_income <- get_acs(geography = 'county',
                         variables = variables,
                         state = 'MD',
                         year = 2018,
                         geometry = TRUE)

ggplot(county_income) + 
  geom_sf(aes(fill = estimate), color = NA) + 
  coord_sf() + 
  theme_minimal() + 
  scale_fill_viridis_c()

## Paging & Stashing

api <- 'https://api.nal.usda.gov/fdc/v1/'
path <- 'foods/search'

query_params <- list('api_key' = Sys.getenv('DATAGOV_KEY'),
                     'query' = 'fruit')

# pipe to GET() to content()
# as = 'parsed' convret the JSON content to nested list
doc <- GET(paste0(api, path), query = query_params) %>%
  content(as = 'parsed')

nutrients <- map_dfr(fruit$foodNutrients, 
                     ~ data.frame(name = .$nutrientName, 
                                  value = .$value))

library(DBI) 
library(RSQLite)

fruit_db <- dbConnect(SQLite(), 'fruits.sqlite') 

query_params$pageSize <- 100

for (i in 1:10) {
  # Advance page and query
  query_params$pageNumber <- i
  response <- GET(paste0(api, path), query = query_params) 
  page <- content(response, as = 'parsed')

  # Convert nested list to data frame
  values <- tibble(food = page$foods) %>%
    unnest_wider(food) %>% # nested list into cols of df
    unnest_longer(foodNutrients) %>%
    unnest_wider(foodNutrients) %>%
    filter(grepl('Sugars, total', nutrientName)) %>%
    select(fdcId, description, value) %>%
    setNames(c('foodID', 'name', 'sugar'))
  
  # Stash in database
  dbWriteTable(fruit_db, name = 'Food', value = values, append = TRUE)
  
}

fruit_sugar_content <- dbReadTable(fruit_db, name = 'Food')

#disconnect from db
dbDisconnect(fruit_db)


## Exercise 1
# Create a df with pop of all countries in the world
# by scraping Wikipedia list of countries by pop
library(rvest)
url <- 'https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population'
doc <- read_html(url)
table_node <- html_node(doc, xpath='//*[@id="mw-content-text"]/div/table[1]')
pop_table <- html_table(table_node)


## Exercise 2
# identify the name of the census variables in the table
# whose "Concept" column includes "COUNT OF THE POPULATION"
# Use Census API to collect data for variable, or every county
# in maryland (FIPS code 24) into a dataframe

library(tidyverse)
library(tidycensus)
source('census_api_key.R') # need file & API key

# Using the previously created census_vars table, find the variable ID for population count.
census_vars <- set_tidy_names(census_vars)
population_vars <- census_vars %>%
  filter(grepl('COUNT OF THE POPULATION', Concept))
pop_var_id <- population_vars$Name[1]

# Use tidycensus to query the API.
county_pop <- get_acs(geography = 'county',
                      variables = pop_var_id,
                      state = 'MD',
                      year = 2018,
                      geometry = TRUE)

# Map of counties by population
ggplot(county_pop) + 
  geom_sf(aes(fill = estimate), color = NA) + 
  coord_sf() + 
  theme_minimal() + 
  scale_fill_viridis_c()
library(tidyverse)
library(tidycensus)
source('census_api_key.R')



## Exercise 3
# Use the FoodData Central API to collect 3 pages
# of food results matching a search term of your choice
# save the names of the foods & nutrient value of your choice
# into a new SQLite

library(httr)
library(DBI) 
library(RSQLite)

source('datagov_api_key.R') # need to request api key

api <- 'https://api.nal.usda.gov/fdc/v1/'
path <- 'foods/search'

query_params <- list('api_key' = Sys.getenv('DATAGOV_KEY'),
                     'query' = 'cheese',
                     'pageSize' = 100)

# Create a new database
cheese_db <- dbConnect(SQLite(), 'cheese.sqlite') 

for (i in 1:3) {
  # Advance page and query
  query_params$pageNumber <- i
  response <- GET(paste0(api, path), query = query_params) 
  page <- content(response, as = 'parsed')
  
  # Convert nested list to data frame
  values <- tibble(food = page$foods) %>%
    unnest_wider(food) %>%
    unnest_longer(foodNutrients) %>%
    unnest_wider(foodNutrients) %>%
    filter(grepl('Protein', nutrientName)) %>%
    select(fdcId, description, value) %>%
    setNames(c('foodID', 'name', 'protein'))
  
  # Stash in database
  dbWriteTable(cheese_db, name = 'Food', value = values, append = TRUE)
  
}

dbDisconnect(cheese_db)
