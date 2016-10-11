library(shiny)

clust_size <- 5

spreads <- readRDS('normalized_sp.RData')
topfives <- readRDS('clust_topmembers.RData')



# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  clust_id <- 4
  
  output$spreads_plot <- renderPlot({
    symbol <- topfives[[clust_id]]$top5[1]
    plot(as.xts(spreads[[symbol]]))
    for (i in 2:4){
      symbol <- topfives[[clust_id]]$top5[i]
      lines(as.xts(spreads[[symbol]]))
    }
  })
  
  output$members <- renderUI({
    ui_output_list <- lapply(1:clust_size, function(i) {
      leftname <- paste("plot", i, sep="")
      rightname <- paste("return", i, sep="")
      fluidRow(
          column(5, plotOutput(leftname)),
          column(5, verbatimTextOutput(rightname))
        )
    })
    
    # Convert the list to a tagList - this is necessary for the list of items
    # to display properly.
    do.call(tagList, ui_output_list)
  })
  
  observe({
    if(is.null(input$select)) return()
    
    for (i in 1:clust_size) {
      # Need local so that each item gets its own number. Without it, the value
      # of i in the renderPlot() will be the same across all instances, because
      # of when the expression is evaluated.
      local({
        my_i <- i
        leftname <- paste("plot", my_i, sep="")
        rightname <- paste("return", my_i, sep="")
        
        output[[leftname]] <- renderPlot({
          plot(1:100)
        })
        
        output[[rightname]] <- renderText({
          'abcd\ndefg\nhighk'
        })
      })
    }
  })
  
  
  

  
  
  
})