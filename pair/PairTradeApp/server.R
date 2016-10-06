require(lubridate)
library(shiny)


# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  
  source('ecpplot.R')
  
  params <- reactiveValues(
    start.est = start.est.feb,
    end.est = end.est.feb,
    entry = entry.feb,
    exit = exit.feb,
    model = model.feb,
    relvec = relvec.feb,
    glob_mean = glob_mean.feb,
    glob_sd = glob_sd.feb,
    residual.est = residual.est.feb,
    residual.position = residual.position.feb
  )
  
  
  observe({
    
    if(is.null(input$pair_entry)) return()
    
    entry <- ymd(as.Date(as.integer(input$pair_entry)))
    start.est <- entry %m-% months(as.integer(input$window_len)) + days(1)
    end.est <- entry
    #exit <- entry + weeks(input$holding_len) #ymd(as.Date(as.integer(input$pair_exit)))
    list[model, relvec, residual.est, glob_mean, glob_sd] <- estimationCalc( start.est, end.est)
    #list[TSAlign.position, residual.position] <- positionCalc(entry, exit, relvec)
    
    params$start.est = start.est
    params$end.est = end.est
    params$entry = entry
    params$exit = NULL #exit
    params$model = model
    params$relvec = relvec
    params$glob_mean = glob_mean
    params$glob_sd = glob_sd
    params$residual.est = residual.est
    params$residual.position = NULL #residual.position
 
  })
  
  observe(
  {
    if(input$preset == 1) {
#       params$start.est = start.est.feb
#       params$end.est = end.est.feb
#       params$entry = entry.feb
#       params$exit = exit.feb
#       params$model = model.feb
#       params$relvec = relvec.feb
#       params$glob_mean = glob_mean.feb
#       params$glob_sd = glob_sd.feb
#       params$residual.est = residual.est.feb
#       params$residual.position = residual.position.feb
      
      updateDateInput(session,"pair_entry", value=as.character(entry.feb))
      updateSliderInput(session, "window_len",value = 12)
    }
    else if (input$preset == 2) {
#       params$start.est = start.est.june
#       params$end.est = end.est.june
#       params$entry = entry.june
#       params$exit = exit.june
#       params$model = model.june 
#       params$relvec = relvec.june
#       params$glob_mean = glob_mean.june
#       params$glob_sd = glob_sd.june
#       params$residual.est = residual.est.june
#       params$residual.position = residual.position.june
      
      updateDateInput(session,"pair_entry", value=as.character(entry.june))
      updateSliderInput(session, "window_len",value = 12)
    }
    
  })
  
  observe({
    output$est_window <- renderText({sprintf("From: %s To: %s",as.character(params$start.est), as.character(params$end.est))})
    
    output$glob_plot <- renderPlot({
      par(mar=c(4,4,1,2))
      plot(params$residual.est, ylim=c(params$glob_mean-2.1*params$glob_sd, params$glob_mean+2.1*params$glob_sd),main="")
      abline(h=params$glob_mean,col='blue')
      abline(h=params$glob_mean+2*params$glob_sd,col='red')
      legend('bottomright',c('spread','mean','mean + 2*sd'),lty=1, col=c('black', 'blue', 'red'), bty='n')
    })
    
    output$glob_report <- renderUI({
      fixedRow(style="margin-left: 40px;",
        column(7,
            verbatimTextOutput("modelstat")
        ),column(4,
                 htmlOutput("spread_detail")
        )
      )
    })
    
    output$modelstat <- renderText({
      estReport(params$model)
    })
    
    output$spread_detail <- renderUI({
      ratio <- params$relvec[2]
      today <- as.character(params$entry)
      spread_today <- params$residual.est[today]
      latex <- c('\\[',
                 '\\begin{align}',
                 '\\gamma &=%2f \\\\', # '\\omega(t) &= \\log(\\text{Close}_{USDGBP}(t)) %.2f \\log(\\text{Close}_{GSK}(t)) \\\\',
                 '\\text{mean}(\\omega) &= %.2f \\\\',
                 '\\text{std}(\\omega) &= %.2f \\\\',
                 '\\omega(\\text{date}) &= %2.f \\\\',
                 '\\textbf{z-score} &= %.2f',
                 '\\end{align}',
                 '\\]')
      withMathJax(
        h4("Estimated result"),
        tags$span(sprintf(paste(latex,collapse = ''), ratio, params$glob_mean,params$glob_sd, spread_today,(params$residual.est[as.character(params$entry)] - params$glob_mean)/params$glob_sd ))
        #tags$span(sprintf("\\(\\text{MEAN}(\\omega)=%.2f \\text{ SD}(\\omega)=%.2f \\textbf{ z-score}=%.2f\\)", params$glob_mean, params$glob_sd,0.0))
      )
    })

    output$loc_report <- renderUI({
      fluidRow(style="margin-left: 40px;",
               column(7, 
                      verbatimTextOutput("locModelstat")
               ),
               column(4,
                      htmlOutput("locSpreadstat")
               )
      )
    })
        
    output$loc_plot <- renderPlot({
      par(mar=c(4,2,1,2))
      res <- params$residual.est
      output = e.divisive(as.matrix(res,ncol=1), sig.lvl = 0.05, R = 199, k = NULL, min.size = 30, alpha = 1)
      list[params[['dynamic_mean']],params[['demean_sd']]] <- plot_dynamic_mean(res, output$estimates)
    })
    

    output$locModelstat <- renderText({
      estReport(params$model)
    })
    
    output$locSpreadstat <- renderUI({
      #if(is.null()) return ()
      ratio <- params$relvec[2]
      today <- as.character(params$entry)
      spread_today <- params$residual.est[today]
      latex <- c('\\[',
                 '\\begin{align}',
                 '\\gamma &=%2f \\\\', # '\\omega(t) &= \\log(\\text{Close}_{USDGBP}(t)) %.2f \\log(\\text{Close}_{GSK}(t)) \\\\',
                 '\\text{mean}(\\omega) &= %.2f \\\\',
                 '\\text{std}(\\omega) &= %.2f \\\\',
                 '\\omega(\\text{date}) &= %2.f \\\\',
                 '\\textbf{z-score} &= %.2f',
                 '\\end{align}',
                 '\\]')
      div(
        h4("Estimated result"),
        tags$span(sprintf(paste(latex,collapse = ''), ratio, params$dynamic_mean,params$demean_sd, spread_today,(params$residual.est[today] - params$dynamic_mean)/params$demean_sd ))
        #tags$span(sprintf("\\(\\text{MEAN}(\\omega)=%.2f \\text{ SD}(\\omega)=%.2f \\textbf{ z-score}=%.2f\\)", params$glob_mean, params$glob_sd,0.0))
      )
    })
    
#     output$holding_spread <- renderPlot({
#       #residual.post <- as.xts(t(model@V[,1]%*%t(log(TSAlign['2015-02-25/',]))))
#       res <- params$residual.position
#       output = e.divisive(as.matrix(res,ncol=1), sig.lvl = 0.05, R = 199, k = NULL, min.size = 30, alpha = 1)
#       plot_dynamic_mean(res, output$estimates)
#     })
  })
  
})