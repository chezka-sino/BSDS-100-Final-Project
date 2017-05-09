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
library(quantmod)
# source("ggplotCombine.R")

max_plots <- 10

shinyServer(function(input, output) {
  
  formulaText <- reactive({
    input$text
  })
  
  output$caption <- renderText({
    formulaText()
    # input$variable
  })
  
  stocks <- reactiveValues()

  # observeEvent(input$add, {
  #   stocks$dList <- c(isolate(stocks$dList), input$text)
  # })
  
  output$list <- renderText({
    stocks$dList
  })
  
  output$metrics <- renderTable({
    getMetrics(input$text)
  })
  
  output$stockPlot <- renderPlot({
    
    # inputStockName = "GOOG"
    # 
    # stockData = createStockData(inputStockName)
    
    # if (input$text) {
    #   df <- data.frame()
    #   ggplot(df) + geom_point() + xlim(0, 10) + ylim(0, 100)
    # }
    
    stockData <- createStockData(input$text)
    print(stockData)
    inputStockName <- paste(input$text, ".", input$variable, sep="")

    # Note! input$variable needs the format [stockName.varaible] e.g. "GOOG.Adj.Close"
    # So I suggest concat or paste stockName+input$variable

    # data <- data.frame(date = row.names(stockData), var = stockData[["GOOG.Adj.Close"]])
    # ggplot(data, aes(as.Date(date, "%Y-%m-%d"), var)) + geom_line()
    stockData <- stockData[which(as.Date(row.names(stockData), "%Y-%m-%d") > max(as.Date(row.names(stockData), "%Y-%m-%d")) - 
                                   as.numeric(input$select)),]
    
    data <- data.frame(date = row.names(stockData), var = stockData[[inputStockName]])
    y.lab <- paste(input$variable, "Price", sep=" ")
    x.lab <- ""
    
    # Harcoded 2017 x-axis label
    if (input$select == "9" | input$select == "32" | input$select == "92") {
      x.lab <- 2017
    }
    
    if (input$variable == "Volume") {
      y.lab <- "Volume"
    }
    ggplot(data, aes(as.Date(date, "%Y-%m-%d"), var)) + geom_line() + labs(y = y.lab, x = x.lab)
    
    
  })
    
    
    
  # })
  
  # Helper methods
  
  createStockData <- function(inputStockName) {
    
    stockData <- getSymbols(inputStockName,auto.assign = FALSE)
    
    stockDF <- as.data.frame(stockData)
    
    return(stockDF)
  }
  
  plotGraph <- function(inputDF) {
    
    ggplot(inputDF, aes(x=as.Date(date, "%Y-%m-%d"), y=var)) + geom_line()
    
  }
  
  plotMultiGraph <- function(inputDF_1,inputDF_2=NULL,inputDF_3=NULL,inputDF_4=NULL) {
    
    ggplot(data=inputDF_1, mapping= aes( x = as.Date(date, "%Y-%m-%d"), y=var )) + geom_line(
      data=inputDF_1) + geom_line(data=inputDF_2) + geom_line(data=inputDF_3) + geom_line(data=inputDF_4)
  }
  
  ## Accepts input of character vectors with stock symbols
  ## E.g. "APPL" for one stock, or c("APPL","GOOG","UAL") for multiple
  ## Returns a data frame with the metrics
  getMetrics <- function(inputStockName) {
    
    what_metrics <- yahooQF(c("Price/Sales", 
                              "P/E Ratio",
                              "Price/EPS Estimate Next Year",
                              "PEG Ratio",
                              "Dividend Yield", 
                              "Market Capitalization"))
    
    tickers <- c(inputStockName)
    
    # Get the metrics
    # Not all the metrics are returned by Yahoo.
    metrics <- getQuote(paste(tickers, sep="", collapse=";"), what=what_metrics)
    
    #Add tickers as the first column and remove the first column which had date stamps
    metrics <- data.frame(Symbol=tickers, metrics[,2:length(metrics)]) 
    
    #Change colnames
    colnames(metrics) <- c("Symbol", "Revenue Multiple", "Earnings Multiple", 
                           "Earnings Multiple (Forward)", "Price-to-Earnings-Growth", "Div Yield", "Market Cap")
    
    return(metrics)    
  }
  
})