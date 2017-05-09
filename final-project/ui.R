#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
# shinyUI(fluidPage(
#   
#   # Application title
#   titlePanel("Old Faithful Geyser Data"),
#   
#   # Sidebar with a slider input for number of bins 
#   sidebarLayout(
#     sidebarPanel(
#        sliderInput("bins",
#                    "Number of bins:",
#                    min = 1,
#                    max = 50,
#                    value = 30)
#     ),
#     
#     # Show a plot of the generated distribution
#     mainPanel(
#        plotOutput("distPlot")
#     )
#   )
# ))

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Stocks"),
  
  sidebarPanel(
    selectInput("variable", "Variable:",
                list("Adj Close" = "Adj.Close",
                     "Open" = "Open",
                     "High" = "High",
                     "Low" = "Low",
                     "Close" = "Close",
                     "Volume" = "Volume")),
    
    # checkboxInput("outliers", "Show outliers", FALSE),
    
    # br(),
    
    textInput('text', 'Stock', 'Text'),
    submitButton("Submit")
    # actionButton('add', 'Add to List')
    # verbatimTextOutput('list')
    
  ),
  
  mainPanel(
    h3(textOutput("caption")),
    
    plotOutput("stockPlot")
  )
  
))
