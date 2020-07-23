library(shiny)
# User Interface
ui <- navbarPage(title = 'Hello, Shiny World!')

# Server
server <- function(input, output) {}

# Create the Shiny App
shinyApp(ui=ui, server = server)
