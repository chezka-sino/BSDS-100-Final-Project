
#Load necessary libraries

require(quantmod)

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

## Outputs a data frame with metrics data
metricDF <- getMetrics(c("AAPL","GOOG"))

metricDF

# OR Single Stock

metricDF2 <- getMetrics("AAPL")

metricDF2



