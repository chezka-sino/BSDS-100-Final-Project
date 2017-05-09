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
                list("Adj Close" = "Adjusted",
                     "Open" = "Open",
                     "High" = "High",
                     "Low" = "Low",
                     "Close" = "Close",
                     "Volume" = "Volume")),
    
    selectInput("select", "Time Frame:",
                list("1 Week" = 9,
                     "1 Month" = 32,
                     "3 Months" = 92,
                     "1 Year" = 367,
                     "3 Years" = 1097,
                     "5 Years" = 1827), selected = 367),
    
    # checkboxInput("outliers", "Show outliers", FALSE),
    
    textInput('text', 'Stock:', 'GOOG'),
    submitButton("Submit")
    # actionButton('add', 'Add to List')
    # verbatimTextOutput
 
  ),
  
  mainPanel(
    h3(textOutput("caption")),
    
    plotOutput("stockPlot"),
    
    br(),
    
    tableOutput("metrics"),
    
    br(),
    
    plotOutput("wordCloud"),
    
    h4(textOutput("newsTitle")),
    
    tableOutput("news")
    
  )
  
))
