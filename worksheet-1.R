## Editor

vals <- ...

vals <- seq(...,
  ...)

## Load Data

storm <- read.csv('data/StormEvents.csv')

storm <- read.csv(
  'data/StormEvents.csv',
  na.string = c('NA', "UNKNOWN"))

# structure?
typeof(storm)

#dimensions
dim(storm)

# Names of Columns
names(storm)

## Lists

x <- list('abc', 1:3, sin)


## Factors

education <- factor(
  c('college', 'highschool', 'college', 'middle', 'middle'),
  levels = c('middle', 'highschool', 'college'))

# Structure of Education
str(education)

## Data Frames

income <- c(32000, 28000, 89000, 0, 0)
df <- data.frame(income, education)

## Names

names(df) <- c('in', 'ed')

## Subsetting ranges

days <- c(
  'Sunday', 'Monday', 'Tuesday',
  'Wednesday', 'Thursday', 'Friday',
  'Saturday')
weekdays <- days[2:6]
weekends <- days[c(1,7)]


# Finding rows, logical statement
df[df$ed == 'college', ]

## Functions

first <- function(a) {
  result <- a[1, ]
  return(result)
}

## Flow Control

# for vectors & dataframes

first <- function(dat) {
  if(is.vector(dat)) {
    result <- dat[[1]]
  } else {
    result <- dat[1, ]
  }
  return(result)
}

## Distributions and Statistics
# random number
rnorm(n = 10)

x <- rnorm(n = 100, mean = 15, sd = 7)
y <- rbinom(n = 100, size = 20, prob = .85)
# t test
t.test(x,y)
# shapiro test
shapiro.test(y)
