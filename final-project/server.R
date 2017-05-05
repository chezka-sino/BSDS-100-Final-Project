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

stockData <- read.csv("pandasTest.csv", header=TRUE, stringsAsFactors = FALSE)

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
    
    data <- data.frame(date = stockData$Date, var = stockData[[input$variable]])
    ggplot(data, aes(as.Date(date, "%Y-%d-%m"), var)) + geom_line() + ylab(input$variable) + xlab("Date")
    
  })
  
})