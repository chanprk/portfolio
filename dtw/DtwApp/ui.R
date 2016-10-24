
library(shiny)

one.sidebarPanel <- wellPanel(id='control',
    selectInput("cluster_id","Cluster:", choices=c('Cluster 1' = 1,'Cluster 2' = 2,'Cluster 3' = 3,'Cluster 4' = 4, 'Cluster 5' = 5 ), selected=1),
    br(),
    uiOutput("control2")
  )


one.mainPanel <- div(id="display-wrapper",verticalLayout(plotOutput("display",height = "40%"), uiOutput("summary")))

one.dashboard <- splitLayout(cellWidths = c("35%", "65%"),one.sidebarPanel, one.mainPanel)
  

# Define UI for application that draws a histogram
shinyUI(navbarPage("Stock Clustering",
      tabPanel("Introduction",
                      withMathJax(),
                        splitLayout( 
                                    cellWidths = c("45%", "50%"),
                                    column(12, 
                                           id='intro-text', 
                                           includeMarkdown('Intro.md')
                                           ),
                                    plotOutput("cluster_plot")
                                   )
                          
                      ),
      tabPanel("Analysis",
               includeCSS("app.css"),
               one.dashboard)
))