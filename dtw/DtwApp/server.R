library(shiny)
library(xts)
require(dtwclust)
require(markdown)
library(stringr)
library(png)

components <- read.csv('FTSE100.csv')
name_dict <- split(components, components$ticker)
#model <- readRDS('model_by_prices.RData')


tickerExt <- function(label) {
  ticker <- str_match_all(label, "LSE.([A-Z]+)\\b")[[1]][2]
  fullname <- as.character(name_dict[[ticker]][['name']])
  ifelse(length(fullname), fullname, ticker)
}

shadeArea <- function(cluster_id) {
  usr <- par('usr')
  if(cluster_id == 1) {
    # rect(
    #   c(as.POSIXct("2016-09-05"), as.POSIXct("2016-10-03")), #David Davis
    #   usr[3],
    #   c(as.POSIXct("2016-09-09"), as.POSIXct("2016-10-14")), #Friday
    #   usr[4], col='palevioletred2', border=NA
    # )
    
    rect(
      c(as.POSIXct("2016-06-24"),as.POSIXct("2016-08-04"), as.POSIXct("2016-09-14")), 
      usr[3], 
      c(as.POSIXct("2016-07-11"),as.POSIXct("2016-08-15"), as.POSIXct("2016-09-22")), 
      usr[4], col='palegreen', border=NA
    )
  } else if(cluster_id == 2) {
    rect(
      c(as.POSIXct("2016-08-04"), as.POSIXct("2016-09-15")), 
      usr[3], 
      c(as.POSIXct("2016-09-05"), as.POSIXct("2016-09-22")), 
      usr[4], col='palegreen', border=NA
    )
    
    rect(
      c(as.POSIXct("2016-07-01"), as.POSIXct("2016-10-06")), 
      usr[3], 
      c(as.POSIXct("2016-07-06"), as.POSIXct("2016-10-14")), 
      usr[4], col='palevioletred2', border=NA
    )
    
    #abline(v=as.POSIXct('2016-07-04'),col='red')
    #abline(v=as.POSIXct('2016-07-01'),col='red')
  } else if(cluster_id == 3) {
    rect(
      c(as.POSIXct("2016-06-24"), as.POSIXct("2016-08-04"), as.POSIXct("2016-09-15")), 
      usr[3], 
      c(as.POSIXct("2016-07-11"), as.POSIXct("2016-08-16"), as.POSIXct("2016-09-23")), 
      usr[4], col='palegreen', border=NA
    )
    
  } else if(cluster_id == 4){
    abline(v=as.POSIXct('2016-06-27'),col='red')
    abline(v=as.POSIXct('2016-07-07'),col='red')
    abline(v=as.POSIXct('2016-08-03'),col='red')

  }else if(cluster_id == 5) {
    
    rect(
     c(as.POSIXct("2016-07-06"), as.POSIXct("2016-08-04")), 
     usr[3], 
     c(as.POSIXct("2016-07-13"), as.POSIXct("2016-09-05")), 
     usr[4], col='palegreen', border=NA
    )
    
    rect(
      c(as.POSIXct("2016-09-05")), 
      usr[3], 
      c(as.POSIXct("2016-10-07")), 
      usr[4], col='palevioletred2', border=NA
    )
    
    
  }
}



clust_size <- 9
color = grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]
plot_colors <- sample(color, 10)

params = list()
params[[1]] = list()
params[[1]][['selected']] = c(1:3,5,10)
params[[1]][['ylim']] = c(0.9, 1.25)

params[[2]] = list()
params[[2]][['selected']] = c(1,2,3,4,7,9)
params[[2]][['ylim']] = c(0.75, 1.2)

params[[3]] = list()
params[[3]][['selected']] = c(1:5,7,9)
params[[3]][['ylim']] = c(0.95, 1.3)

params[[4]] = list()
params[[4]][['selected']] = 1:9
params[[4]][['ylim']] = c(0.85, 1.5)

params[[5]] = list()
params[[5]][['selected']] = c(3:5,7:10)
params[[5]][['ylim']] = c(0.7, 1.25)

params[[6]] = list()
params[[6]][['selected']] = c(1,2,4)
params[[6]][['ylim']] = c(0.80, 1.20)


spreads <- readRDS('normalized_sp.RData')
prices <- readRDS('FTSE100XTS.RData')
prices <- as.xts(prices)['/2016-10-07']

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  topmems <- readRDS('topmems_by_prices.RData')
  
  
  output$control2 <- renderUI({
    if(is.null(input$cluster_id)) return()
    
    clust_id <- as.numeric(input$cluster_id)
    choices <- 1:length(topmems[[clust_id]]$topten)
    names(choices) <- sapply(topmems[[clust_id]]$topten,tickerExt)
    checkboxGroupInput("members", "Top Ten Members:", choices, selected = params[[clust_id]]$selected)
  })
  
  
  output$display <- renderPlot({
    if(is.null(input$cluster_id)) return()
    if(is.null(input$members)) return()      
    
    clust_id <- as.numeric(input$cluster_id)
    
    par(mar=c(4,6,1,3))
    symbol <- topmems[[clust_id]]$topten[1]
    serie <- prices[,symbol]
    
    plot( serie / as.numeric(serie[1]),  type='n', main="",ylab="Price", ylim=params[[clust_id]]$ylim)
    
    shadeArea(clust_id)
    
    line_colors <- paste(rep('gray',10), 41:50, sep="")
    for (i in input$members){
      i <- as.numeric(i)
      symbol <- topmems[[clust_id]]$topten[i]
      #cat(as.numeric(i))
      serie <- prices[,symbol]
      lines(serie / as.numeric(serie[1]), col=line_colors[i])#, col=plot_colors[[i]])
    }
    
  })
  

  output$summary <- renderUI({
    if(is.null(input$cluster_id)) return()
    markdownFile <- paste('clust',input$cluster_id,'_text.md',sep="")
    column(12,
           br(),
           includeMarkdown(markdownFile), 
           style = "font-family: 'Source Sans Pro';font-size: 12pt; white-space: normal;")
    
  })
  

  
})