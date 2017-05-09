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
  headerPanel("Stocks Visualizer"),
  
  sidebarPanel(
    selectInput("variable", "Variable:",
                list("Adj Close" = "Adjusted",
                     "Open" = "Open",
                     "High" = "High",
                     "Low" = "Low",
                     "Close" = "Close",
                     "Volume" = "Volume")),
    
    selectInput("select", "Time Frame",
                list("1 Week" = "last 1 week",
                     "1 Month" = "last 1 month",
                     "3 Months" = "last 3 month",
                     "1 Year" = "last 1 year",
                     "3 Years" = "last 3 year",
                     "5 Years" = "last 5 year"), selected = "last 1 year"),
    
    # checkboxInput("outliers", "Show outliers", FALSE),
    
    checkboxGroupInput("TA", "Technical Indicators:",
                       choiceNames =
                         list("Simple Moving Average","Bollinger Bands"),
                       choiceValues =
                         list("addSMA();", "addBBands();")
    ),
    textOutput("txt"),
    
    textInput('text', 'Stock Symbol:', 'GOOG'),
    submitButton("Submit")
    # actionButton('add', 'Add to List')
    # verbatimTextOutput
 
  ),
  
  mainPanel(
    h3(textOutput("caption")),
    
    plotOutput("stockPlot", height = 750, width = 850),
    
    br(),
    
    tableOutput("metrics"),
    
    br(),
    
    plotOutput("wordCloud", height = 750, width = 1000),
    
    h4(textOutput("newsTitle")),
    
    lapply(1:10, function(i) {
      uiOutput(paste0('b', i))
    }),
    
    h5(textOutput("ending"))
    
    
  )
  
))
