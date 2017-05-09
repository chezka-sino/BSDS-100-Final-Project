#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

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
    
    selectInput("select", "Time Frame",
                list("1 Week" = 9,
                     "1 Month" = 32,
                     "3 Months" = 92), selected = 32),
    
    # checkboxInput("outliers", "Show outliers", FALSE),
    
    textInput('text', 'Stock', 'GOOG'),
    submitButton("Submit")
    # actionButton('add', 'Add to List')
    # verbatimTextOutput
 
  ),
  
  mainPanel(
    h3(textOutput("caption")),
    
    plotOutput("stockPlot")
  )
  
))
