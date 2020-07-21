## Tidy Concept

setwd('/home/katelyn/')

trial <- read.delim(sep = ',', header = TRUE, text = "
block, drug, control, placebo
    1, 0.22,    0.58,    0.31
    2, 0.12,    0.98,    0.47
    3, 0.42,    0.19,    0.40
")

## Pivot wide to long 

library(tidyr)
tidy_trial <- pivot_longer(trial,
                           cols = c(drug, control, placebo),
                           names_to = 'treatment',
                           values_to = 'response')
## Pivot long to wide 

survey <- read.delim(sep = ',', header = TRUE, text = "
participant,   attr, val
1          ,    age,  24
2          ,    age,  57
3          ,    age,  13
1          , income,  30
2          , income,  60
")

tidy_survey <- pivot_wider(survey,
                           names_from = attr,
                           values_from = val)


## Sample Data 

library(data.table)
cbp <- fread('data/cbp15co.csv')

cbp <- fread(
  'data/cbp15co.csv',
  colClasses = c(
    FIPSTATE='character',
    FIPSCTY='character'))

acs <- fread(
  'data/ACS/sector_ACS_15_5YR_S2413.csv',
  colClasses = c(FIPS = 'character'))

## dplyr Functions 

library(dplyr)
cbp2 <- filter(cbp,
               grepl('----', NAICS),
               !grepl('------', NAICS))

library(stringr)
cbp2 <- filter(cbp,
               str_detect(NAICS, '[0-9]{2}----'))

cbp3 <- mutate(cbp2,
               FIPS = str_c(FIPSTATE, FIPSCTY))

cbp3 <- mutate(cbp2,
               FIPS = str_c(FIPSTATE, FIPSCTY),
               NAICS = str_remove(NAICS, '-+'))

cbp <- cbp %>%
  filter(
    str_detect(NAICS, '[0-9]{2}----')
  ) %>%
  mutate(
    FIPS = str_c(FIPSTATE, FIPSCTY),
    NAICS = str_remove(NAICS, '-+')
  )

cbp <- cbp %>%
  select(
    FIPS,
    NAICS,
    starts_with('N')
  )

## Join

sector <- fread(
  'data/ACS/sector_naics.csv',
  colClasses = c(NAICS = 'character'))

cbp <- cbp %>%
  inner_join(sector)

## Group By 

cbp_grouped <- cbp %>%
  group_by(FIPS, Sector)

## Summarize 

cbp <- cbp %>%
  group_by(FIPS, Sector) %>%
  select(starts_with('N'), -NAICS) %>%
  summarize_all(sum)

acs_cbp <- cbp %>%
  inner_join(acs)


# Exercise
long_survey <- pivot_longer(tidy_survey,  
                            cols=c(age, income), 
                            values_to = 'val', 
                            names_to = 'attr', 
)

