library(shiny)
library(xts)
library(stringr)

tickerExt <- function(label) {
  str_match_all(label, "LSE.([A-Z]+)\\b")[[1]][2]
}

clust_size <- 5

plot_colors <- list('blue2','green','coral2','darkseagreen4','gray50')
params = list()
params[[1]] = list()
params[[1]][['selected']] = 1:3
params[[1]][['ylim']] = c(0.8, 1.4)

params[[2]] = list()
params[[2]][['selected']] = 1:3
params[[2]][['ylim']] = c(0.9, 1.25)

params[[3]] = list()
params[[3]][['selected']] = 1:3
params[[3]][['ylim']] = c(0.9, 1.15)

params[[4]] = list()
params[[4]][['selected']] = 1:3
params[[4]][['ylim']] = c(0.85, 1.35)

params[[5]] = list()
params[[5]][['selected']] = 1:3
params[[5]][['ylim']] = c(0.95, 1.4)

params[[6]] = list()
params[[6]][['selected']] = c(1,2,4)
params[[6]][['ylim']] = c(0.80, 1.20)


spreads <- readRDS('normalized_sp.RData')
topfives <- readRDS('topmems.RData')
prices <- readRDS('FTSE100XTS.RData')

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

  
  output$control2 <- renderUI({
    if(is.null(input$cluster_id)) return()
    
    clust_id <- as.numeric(input$cluster_id)
    
    choices <- 1:5
    names(choices) <- sapply(topfives[[clust_id]]$topfive,tickerExt)
    checkboxGroupInput("members", "Top Five Members:", choices, inline=TRUE, selected = params[[clust_id]]$selected)
  })
  
  
  output$display <- renderPlot({
    if(is.null(input$cluster_id)) return()
    if(is.null(input$members)) return()
    
    clust_id <- as.numeric(input$cluster_id)
    
    par(mar=c(4,6,1,3))
    symbol <- topfives[[clust_id]]$topfive[1]
    serie <- as.xts(spreads[[symbol]])
    plot(serie,  type='n', main="",ylab="Spread")
    usr <- par('usr')
    rect(
      c(index(serie["2016-07-11"]), index(serie["2016-08-15"])), 
      usr[3], 
      c(index(serie["2016-08-03"]), index(serie["2016-09-15"])), 
      usr[4], col='green', border=NA)
    
    rect(
      c(index(serie["2016-06-23"]), index(serie["2016-08-03"]), index(serie["2016-09-15"])), 
      usr[3], 
      c(index(serie["2016-07-11"]), index(serie["2016-08-15"]), index(serie["2016-10-07"])), 
      usr[4], col='red', border=NA)
    
    #rect(1, usr[3], 3, usr[4], col='red')
    for (i in input$members){
      i <- as.numeric(i)
      symbol <- topfives[[clust_id]]$topfive[i]
      #cat(as.numeric(i))
      lines(as.xts(spreads[[symbol]]),col=plot_colors[[i]])
    }
  })
  
  output$display2 <- renderPlot({
    if(is.null(input$cluster_id)) return()
    if(is.null(input$members)) return()      
    
    clust_id <- as.numeric(input$cluster_id)
    
    par(mar=c(4,6,1,3))
    symbol <- topfives[[clust_id]]$topfive[1]
    serie <- prices[,symbol]
    plot( serie / as.numeric(serie[1]),  type='n', main="",ylab="Price", ylim=params[[clust_id]]$ylim)

    for (i in input$members){
      i <- as.numeric(i)
      symbol <- topfives[[clust_id]]$topfive[i]
      #cat(as.numeric(i))
      serie <- prices[,symbol]
      lines(serie / as.numeric(serie[1]), col=plot_colors[[i]])
    }
  })
  
})