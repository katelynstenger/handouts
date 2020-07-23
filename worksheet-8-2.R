library(shiny)

# Data
popdata <- read.csv('data/citypopdata.csv')

# User Interface
# inputId: give input object a name to refer in server
# label: text to display to user
in1 <- selectInput(
  inputId = 'selected_city',
  label = 'Select a city',
  choices = unique(popdata[['NAME']]))

# tabPanel place the tab object in the ui page
tab1 <- tabPanel(
  title = 'City Population',
  in1)
ui <- navbarPage(
  title = 'Census Population Explorer',
  tab1)

# selectedInput() function create an input called 'selected_city'
# use choices = to define a vector w/ unique values in NAME
# make the input object argument to the function tabPanel()

## Input object
# "choices" for inputs
# Selectize inputs useful for drop down lists
# Be aware of default value for input object

## Output objects
# Desired UI Object	    render*()	        *Output()
# plot	                renderPlot()	    plotOutput()
# text	                renderPrint()	    verbatimTextOutput()
# text	                renderText()	    textOutput()
# static table	        renderTable()	    tableOutput()
# interactive table	    renderDataTable()	dataTableOutput()


# Server
server <- function(input, output) {
  output[['city_label']] <- renderText({
    input[['selected_city']]
  })
}

out1 <- textOutput('city_label')
tab1 <- tabPanel(
  title = 'City Population',
  in1, out1)

# Create the Shiny App
shinyApp(ui = ui, server = server)
