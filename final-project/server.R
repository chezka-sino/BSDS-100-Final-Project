#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(fImport)

# # Define server logic required to draw a histogram

# shinyServer(function(input, output) {
#    
#   output$distPlot <- renderPlot({
#     
#     # generate bins based on input$bins from ui.R
#     x    <- faithful[, 2] 
#     bins <- seq(min(x), max(x), length.out = input$bins + 1)
#     
#     # draw the histogram with the specified number of bins
#     hist(x, breaks = bins, col = 'darkgray', border = 'white')
#     
#   })
#   
# })

# stockData <- read.csv("pandasTest.csv", header=TRUE, stringsAsFactors = FALSE)

shinyServer(function(input, output) {
  
  formulaText <- reactive({
    input$variable
  })
  
  output$caption <- renderText({
    formulaText()
    # input$variable
  })
  
  sliderValues <- reactive({
    
  })
  
  stocks <- reactiveValues()
  # observe({
  #   if (input$add > 0) {
  #     stocks$dList <- c(isolate(stocks$dList), input$text)
  #   }
  # })
  observeEvent(input$add, {
    stocks$dList <- c(isolate(stocks$dList), input$text)
  })
  
  output$list <- renderText({
    stocks$dList
  })
  
  output$stockPlot <- renderPlot({
    
    inputStockName = "GOOG"
    
    stockData = createStockData(inputStockName)
    
    # Note! input$variable needs the format [stockName.varaible] e.g. "GOOG.Adj.Close"
    # So I suggest concat or paste stockName+input$variable
    data <- data.frame(date = row.names(stockData), var = stockData[["GOOG.Adj.Close"]])
    ggplot(data, aes(as.Date(date, "%Y-%m-%d"), var)) + geom_line() 
    
  })
  
  createStockData <- function(inputStockName) {
    stockTimeSeries = yahooSeries(inputStockName)
    
    stockDF = as.data.frame(stockTimeSeries)
    
    return(stockDF)
    
  }
  
})