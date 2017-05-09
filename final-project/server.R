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
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
require(XML)
require(plyr)
require(stringr)
require(lubridate)

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
    
    stockData <- createStockData(input$text)

    inputStockName <- paste(input$text, ".", input$variable, sep="")

    # Note! input$variable needs the format [stockName.varaible] e.g. "GOOG.Adj.Close"
    # So I suggest concat or paste stockName+input$variable

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
  
  output$wordCloud <- renderPlot({
    filepath <- "news.txt"
    createNewsTXT(input$text, 100, filepath)
    # Read the text file from internet
    # filePath <- "http://www.sthda.com/sthda/RDoc/example-files/martin-luther-king-i-have-a-dream-speech.txt"
    # text <- readLines(filePath)
    
    text <- readLines(filepath)
    drawWordCloud(text)}
    
  )
  
  output$newsTitle <- renderText({
    title <- paste("Top news for ", input$text, ":", sep="")
    title
  })
  
  output$news <- renderTable({
    links <- getNews(input$text, 100)
    urls <- data.frame(links[1:10,2]) 
    urls
  }, colnames = FALSE)
    
  
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
  
  drawWordCloud <- function(text) {
    
    # Load the data as a corpus
    docs <- Corpus(VectorSource(text))
    
    toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
    docs <- tm_map(docs, toSpace, "/")
    docs <- tm_map(docs, toSpace, "@")
    docs <- tm_map(docs, toSpace, "\\|")
    
    # Convert the text to lower case
    docs <- tm_map(docs, content_transformer(tolower))
    # Remove numbers
    docs <- tm_map(docs, removeNumbers)
    # Remove english common stopwords
    docs <- tm_map(docs, removeWords, stopwords("english"))
    # Remove your own stop word
    # specify your stopwords as a character vector
    docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 
    # Remove punctuations
    docs <- tm_map(docs, removePunctuation)
    # Eliminate extra white spaces
    docs <- tm_map(docs, stripWhitespace)
    
    dtm <- TermDocumentMatrix(docs)
    m <- as.matrix(dtm)
    v <- sort(rowSums(m),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    head(d, 10)
    
    set.seed(1234)
    wordcloud(words = d$word, freq = d$freq, min.freq = 1,
              max.words=200, random.order=FALSE, rot.per=0.35, 
              colors=brewer.pal(8, "Dark2"))
    
  }
  
  ## Symbol is stock symbol e.g GOOG
  ## number is the number of stories to download, e.g. 50 will give you 50 stories
  getNews <- function(symbol, number){
    
    
    # construct url to news feed rss and encode it correctly
    url.b1 = 'http://www.google.com/finance/company_news?q='
    url    = paste(url.b1, symbol, '&output=rss', "&start=", 1,
                   "&num=", number, sep = '')
    url    = URLencode(url)
    
    # parse xml tree, get item nodes, extract data and return data frame
    doc   = xmlTreeParse(url, useInternalNodes = T);
    nodes = getNodeSet(doc, "//item");
    mydf  = ldply(nodes, as.data.frame(xmlToList))
    
    # clean up names of data frame
    names(mydf) = str_replace_all(names(mydf), "value\\.", "")
    
    # convert pubDate to date-time object and convert time zone
    mydf$pubDate = strptime(mydf$pubDate, 
                            format = '%a, %d %b %Y %H:%M:%S', tz = 'GMT')
    mydf$pubDate = with_tz(mydf$pubDate, tz = 'America/New_york')
    
    # drop guid.text and guid..attrs
    mydf$guid.text = mydf$guid..attrs = NULL
    
    
    mydf$title <- as.character(mydf$title)
    mydf$link <- as.character(mydf$link)
    mydf$description <- as.character(mydf$description)
    
    ## Remove HTML tags
    regex_html <- "</?\\w+((\\s+\\w+(\\s*=\\s*(?:\".*?\"|'.*?'|[\\^'\">\\s]+))?)+\\s*|\\s*)/?>"
    
    mydf$description <- gsub("\n","",mydf$description)
    
    mydf$description <- gsub(regex_html,"",mydf$description,perl = TRUE)

    return(mydf)    
  }
  
  
  ## symbol e.g. GOOG, number e.g. 50 for 50 stories to download
  # outputFilePath is the location to place the file
  createNewsTXT <- function(symbol,number,outputFilePath="stockNews.txt") {
    
    stockNewsDF <- getNews(symbol,number)
    
    titles <- paste(stockNewsDF$title,collapse = ",")
    
    descriptions <- paste(stockNewsDF$description,collapse = ",")
    
    bigText <- paste(titles,descriptions,sep=" ")
    
    write(bigText,outputFilePath)
    
  }
  
})