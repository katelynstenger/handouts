# Packages
library(ggplot2)
library(dplyr)
library(shiny)


# Server
# must filter the data based on the selected city
# then create a plot within the renderPlot()
server <- function(input, output) {
  output[['city_label']] <- renderText({
    input[['selected_city']]
  })
  output[['city_plot']] <- renderPlot({
    df <- popdata %>% 
      dplyr::filter(NAME == input[['selected_city']])
    ggplot(df, aes(x = year, y = population)) +
      geom_line()
  })
}

# Data
popdata <- read.csv('data/citypopdata.csv')

# plotOutput() to display the plot in the app
out1 <- textOutput('city_label')
out2 <- plotOutput('city_plot')
tab1 <- tabPanel(
  title = 'City Population',
  in1, out1, out2)
ui <- navbarPage(
  title = 'Census Population Explorer',
  tab1)


# Create the Shiny App
shinyApp(ui = ui, server = server)

## Design and Layout
# A suite of *Layout() functions make for a nicer user
#interface. You can organize elements with a page using
# pre-defined high level layouts such as
# 
# sidebarLayout()
# splitLayout()
# verticalLayout()

# The more general fluidRow() allows any organization of 
# elements within a grid. The folowing UI elements, and more,
# can be layered on top of each other in either a fluid page 
# or pre-defined layouts.
# 
# tabsetPanel()
# navlistPanel()
# navbarPage()

side <- sidebarPanel('Options', in1)
main <- mainPanel(out1, out2)
tab1 <- tabPanel(
  title = 'City Population',
  sidebarLayout(side, main))


## Customization
h5('This is a level 5 header.')

# link
a(href = 'https://www.sesync.org',
  'This renders a link')

# Layout Tips & options
# can also use icons:
# https://shiny.rstudio.com/reference/shiny/latest/icon.html
# html tags:
# https://shiny.rstudio.com/articles/tag-glossary.html
# Add images by saving those files in a folder called
# www Embed it with img(src = '<FILENAME')






