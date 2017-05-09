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
# source("ggplotCombine.R")

max_plots <- 10

shinyServer(function(input, output) {
  
  formulaText <- reactive({
    input$variable
  })
  
  output$caption <- renderText({
    formulaText()
    # input$variable
  })
  
  stocks <- reactiveValues()

  observeEvent(input$add, {
    stocks$dList <- c(isolate(stocks$dList), input$text)
  })
  
  output$list <- renderText({
    stocks$dList
    
  })

  
  output$stockPlot <- renderPlot({
    
    # inputStockName = "GOOG"
    # 
    # stockData = createStockData(inputStockName)
    
    stockData <- createStockData(input$text)
    inputStockName <- paste(input$text, ".", input$variable, sep="")

    # Note! input$variable needs the format [stockName.varaible] e.g. "GOOG.Adj.Close"
    # So I suggest concat or paste stockName+input$variable

    # data <- data.frame(date = row.names(stockData), var = stockData[["GOOG.Adj.Close"]])
    # ggplot(data, aes(as.Date(date, "%Y-%m-%d"), var)) + geom_line()
    stockData <- stockData[which(as.Date(row.names(stockData), "%Y-%m-%d") > max(as.Date(row.names(stockData), "%Y-%m-%d")) - 
                                   as.numeric(input$select)),]
    
    data <- data.frame(date = row.names(stockData), var = stockData[[inputStockName]])
    y.lab <- "Price"
    if (input$variable == "Volume") {
      y.lab <- "Volume"
    }
    ggplot(data, aes(as.Date(date, "%Y-%m-%d"), var)) + geom_line() + labs(y = y.lab)
    
    
  })
    
    
    
  # })
  
  # Helper methods
  
  createStockData <- function(inputStockName) {
    stockTimeSeries = yahooSeries(inputStockName)
    
    stockDF = as.data.frame(stockTimeSeries)
    
    return(stockDF)
    
  }
  
  plotGraph <- function(inputDF) {
    
    ggplot(inputDF, aes(x=as.Date(date, "%Y-%m-%d"), y=var)) + geom_line()
    
  }
  
  plotMultiGraph <- function(inputDF_1,inputDF_2=NULL,inputDF_3=NULL,inputDF_4=NULL) {
    
    ggplot(data=inputDF_1, mapping= aes( x = as.Date(date, "%Y-%m-%d"), y=var )) + geom_line(
      data=inputDF_1) + geom_line(data=inputDF_2) + geom_line(data=inputDF_3) + geom_line(data=inputDF_4)
  }
  
})