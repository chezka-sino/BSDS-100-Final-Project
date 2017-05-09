##### Combining GGPlots ####

# library(ggplot2)
# library(fImport)

## Helper Function

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

## Test Code

GOOGStock <- createStockData("GOOG")
UALStock <- createStockData("UAL")
YHOOStock <- createStockData("YHOO")

# Note, maybe have only one data array, in case of multiple and causes bug?, potential api wrong data problem
dataGOOG <- data.frame(date = row.names(GOOGStock), var = GOOGStock[["GOOG.Adj.Close"]])
dataUAL <- data.frame(date = row.names(UALStock), var = UALStock[["UAL.Adj.Close"]])
dataYHOO <- data.frame(date = row.names(YHOOStock), var = YHOOStock[["YHOO.Adj.Close"]])


plotGraph(dataUAL)
plotGraph(dataYHOO)
plotGraph(dataGOOG)

plotMultiGraph(dataUAL,dataGOOG)
plotMultiGraph(dataYHOO,dataGOOG)
plotMultiGraph(dataYHOO,dataUAL)

# Able to call 3 data frames while the fourth data frame is null, can be expanded as necessary easily
plotMultiGraph(dataYHOO,dataUAL,dataGOOG)

# as.Date(date, "%Y-%m-%d")
GOOGStock[which(as.Date(row.names(GOOGStock), "%Y-%m-%d") > (max(as.Date(row.names(GOOGStock), "%Y-%m-%d")) - 9)),]



