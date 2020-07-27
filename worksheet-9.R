# Worksheet for SQLite lesson

# First you will need to copy the portal.sqlite file
# to your own workspace so that your changes to the file
# will not affect everyone else in the class!

file.copy('data/portal.sqlite', 'myportal.sqlite')

library(RSQLite)

# Create a connection object
con <- dbConnect(RSQLite::SQLite(), 
                 "../data/myportal.sqlite")

dbListFields(con, 'species')

# Read a table
library(dplyr)

species <- tbl(con, 'species')
species

# Upload a new table
df <- data.frame(
  id = c(1, 2),
  name = c('Alice', 'Bob')
)

dbReadTable(con, 'observers', df)

## Database Characteristics
# relational database: 
# - primary key: one or more fields uniquely identified a record in a table
# - foreign key: primary key from one table used in diff table to est a relationship
# - query: collect values from tables based on relationships & others

# remove existing observers table
dbRemoveTable(con, 'observers') 

# Recreate observers table

dbCreateTable(con, 'observers', list(
  id = 'integer primary key',
  name = 'text'
))

# add data to observers table
# with auto-generated id

df <- data.frame(
  name = c('Alice', 'Bob')
)
dbWriteTable(con, 'observers', df,
             append = TRUE)


# primary keys checked BEFORE duplicates end up in the data
# throwing an error if necessary
df <- data.frame(
  id = c(1),
  name = c('J. Doe')
)
dbWriteTable(con, 'observers', df,
             append = TRUE)

## Foreign Keys
# A field may also be designated as a foreign key
# establishes a relationships bt tables, 
# a foreign key points to some primary key from diff table

# Try violating foreign key constraint
dbExecute(con, 'PRAGMA foreign_keys = ON;')

df <- data.frame(
  month = 7,
  day = 16,
  year = 1977,
  plot_id = 'Rodent'
)
dbWriteTable(con, 'surveys', df,
             append = TRUE)

# Queries
# interacting with relational databases

# RMarkdown file for sql
# ```{sql connection = con}
# ...
# ```

# basic queries
# SELECT & FROM are SQL keywords
dbGetQuery(con, "SELECT year FROM surveys")

# * is a wildcard
dbGetQuery(con, "SELECT * FROM surveys")

dbGetQuery(con, "SELECT *
FROM surveys")

# limit query response
dbGetQuery(con, "SELECT year, species_id
FROM surveys
LIMIT 4")

# get only unique values
dbGetQuery(con, "SELECT year, species_id
FROM surveys")

dbGetQuery(con, "SELECT DISTINCT species_id
FROM surveys")

# perform calculations 
dbGetQuery(con, "SELECT plot_id, species_id,
  sex, weight / 1000.0
           FROM surveys")

dbGetQuery(con, "SELECT plot_id, species_id, sex,
  weight / 1000 AS weight_kg
FROM surveys")

dbGetQuery(con, "SELECT plot_id, species_id, sex,
  ROUND(weight / 1000.0, 2) AS weight_kg
           FROM surveys")

# filtering
# hint: use alternating single or double quotes to 
# include a character string within another
dbGetQuery(con, "SELECT *
FROM surveys
           WHERE species_id = 'DM'")

dbGetQuery(con, "SELECT *
FROM surveys
WHERE year >= 2000")

dbGetQuery(con, "SELECT *
FROM surveys
           WHERE year >= 2000 AND species_id = 'DM'")

dbGetQuery(con, "SELECT *
FROM surveys
           WHERE (year >= 2000 OR year <= 1990)
           AND species_id = 'DM'")

# Joins
# one to many 
dbGetQuery(con, "SELECT weight, plot_type
FROM surveys
...
  ... = ...")

# many to many
dbGetQuery(con, "SELECT weight, genus, plot_type
FROM surveys
... plots
  ON ...
... species
  ON ...")

## Normalized Data is Tidy
# un-tidy data with JOINs
# SQL "JOIN" 
lm(weight ~ treatment,
   data = portal)

lm(weight ~ genus + treatment,
   data = portal)

## Relations
# one-to-many
# many-to-many

# one-to-many
dbGetQuery(con, "SELECT weight, plot_type
FROM surveys
JOIN plots
  ON surveys.plot_id = plots.plot_id")

# many-to-many
dbGetQuery(con, "SELECT weight, genus, plot_type
FROM surveys
JOIN plots
  ON surveys.plot_id = plots.plot_id
JOIN species
  ON surveys.species_id = species.species_id")


## Summary
# concurrency: 
# reliability: 
# scaleability: 

