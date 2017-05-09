# load libraries
require(XML)
require(plyr)
require(stringr)
require(lubridate)

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
  
  mydf$description <- gsub(regex_2,"",mydf$description,perl = TRUE)
  
  
  
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